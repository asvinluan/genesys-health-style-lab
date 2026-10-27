#!/usr/bin/env python3
"""Static checks for the repo. No network, no Genesys, no credentials. Run before every commit.

    python3 tools/check_repo.py

What it checks, and why each one matters:
  1. No secrets committed (client secrets, AWS keys, private keys).
  2. Every phone number is in the Australian drama range (03 5550 xxxx), so no real person is ever called.
  3. Every module has the four standard files.
  4. Every flow YAML parses, and every {{placeholder}} in it is a queue or flow value that really exists.
  5. The function zip exists (Genesys cannot download it back, so Git is the source of truth).
  6. The design in locals.tf is consistent: every group, division, role, wrap-up code, flow and schedule that is
     named somewhere is defined somewhere. Terraform would only find a mistake at plan time, which needs credentials.
Exit code 0 = all good. Anything else = fix before committing.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TEXT_SUFFIXES = {".tf", ".tfvars", ".yaml", ".yml", ".md", ".sh", ".ps1", ".js", ".json", ".example", ".txt"}
SKIP_DIRS = {".git", ".terraform", "node_modules", "generated", "export"}
problems = []


def files():
    for p in ROOT.rglob("*"):
        if p.is_file() and not (set(p.relative_to(ROOT).parts) & SKIP_DIRS) and (p.suffix in TEXT_SUFFIXES or p.name.startswith(".git")):
            yield p


def fail(msg):
    problems.append(msg)
    print(f"  FAIL  {msg}")


def ok(msg):
    print(f"  OK    {msg}")


# 1. secrets ---------------------------------------------------------------------------------------
SECRET_PATTERNS = [
    (re.compile(r"AKIA[0-9A-Z]{16}"), "AWS access key id"),
    (re.compile(r"-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----"), "private key"),
    (re.compile(r"OAUTHCLIENT_SECRET\s*=\s*['\"]?[A-Za-z0-9_\-]{20,}"), "Genesys client secret assigned"),
    (re.compile(r"client_secret\s*=\s*\"[A-Za-z0-9_\-]{20,}\""), "client secret in HCL"),
    (re.compile(r"\b\d{12}\b(?=.*arn:aws)"), "AWS account id in an ARN"),
]
print("1. Secret scan")
hits = 0
for p in files():
    if p.name == "check_repo.py":
        continue
    text = p.read_text(errors="ignore")
    for rx, label in SECRET_PATTERNS:
        if rx.search(text):
            hits += 1
            fail(f"{label} in {p.relative_to(ROOT)}")
if not hits:
    ok("no secrets found")

# 2. phone numbers ----------------------------------------------------------------------------------
print("2. Phone numbers")
PHONE = re.compile(r"\+61\d{9}")
bad = 0
for p in files():
    if p.suffix in {".md"}:
        continue  # docs may explain real formats
    for m in PHONE.finditer(p.read_text(errors="ignore")):
        if not m.group(0).startswith("+6135550"):
            bad += 1
            fail(f"{m.group(0)} in {p.relative_to(ROOT)} is not in the +61 3 5550 xxxx drama range")
if not bad:
    ok("all numbers are in the drama range")

# 3. module layout ----------------------------------------------------------------------------------
print("3. Module layout")
need = ["main.tf", "variables.tf", "outputs.tf", "versions.tf"]
mods = sorted((ROOT / "terraform" / "modules").iterdir())
missing = 0
for m in mods:
    for n in need:
        if not (m / n).exists():
            missing += 1
            fail(f"{m.name} is missing {n}")
if not missing:
    ok(f"{len(mods)} modules, each with {', '.join(need)}")

# 4. flows ------------------------------------------------------------------------------------------
print("4. Flow YAML")
try:
    import yaml
except ImportError:
    yaml = None
    print("  SKIP  PyYAML not installed (pip install pyyaml); skipping the parse check")

try:
    import hcl2
except ImportError:
    hcl2 = None


def strip_quotes(x):
    """python-hcl2 8.x keeps the quote marks on strings and keys; older versions strip them.
    Normalise to the old shape so this check gives the same answer on every version."""
    if isinstance(x, str):
        return x[1:-1] if len(x) >= 2 and x[0] == '"' and x[-1] == '"' else x
    if isinstance(x, list):
        return [strip_quotes(i) for i in x]
    if isinstance(x, dict):
        return {strip_quotes(k): strip_quotes(v) for k, v in x.items()}
    return x


def wraps_top_level():
    """Older python-hcl2 wraps every top-level value of a locals block in a one-item list. Newer does not."""
    try:
        return isinstance(hcl2.loads('locals {\n  a = "x"\n}\n')["locals"][0]["a"], list)
    except Exception:  # noqa: BLE001
        return False


def unwrap(x):
    return x[0] if WRAPS and isinstance(x, list) and len(x) == 1 else x


L = None
WRAPS = wraps_top_level() if hcl2 else False
if hcl2:
    with open(ROOT / "terraform" / "locals.tf", encoding="utf-8") as fh:
        L = {k: unwrap(v) for k, v in strip_quotes(hcl2.load(fh))["locals"][0].items()}

slugs = set()
if L:
    slugs = {"queue_" + k.lower().replace(" ", "_") for k in L["queues"]}
allowed = {"flow_name", "division_name"} | slugs
flows_dir = ROOT / "terraform" / "flows"
bad = 0
for f in sorted(flows_dir.glob("*.yaml")):
    raw = f.read_text()
    if yaml:
        try:
            doc = yaml.safe_load(raw)
            if not isinstance(doc, dict) or len(doc) != 1:
                bad += 1
                fail(f"{f.name}: expected one top-level key (inboundCall, workflow, ...)")
        except yaml.YAMLError as e:
            bad += 1
            fail(f"{f.name}: YAML does not parse: {e}")
    if L:
        for ph in sorted(set(re.findall(r"{{([a-z_]+)}}", raw))):
            if ph not in allowed:
                bad += 1
                fail(f"{f.name}: placeholder {{{{{ph}}}}} is not a queue or flow value")
if not bad:
    ok("every flow parses and every placeholder is a real queue or flow value")
print("  NOTE  This does not prove Architect accepts the flow. Only Archy (publish --check) or an import does.")

# 5. function zip -----------------------------------------------------------------------------------
print("5. Function package")
z = ROOT / "terraform" / "function-actions" / "normalise-reference" / "dist" / "normalise-reference.zip"
if z.exists():
    ok("dist/normalise-reference.zip exists")
else:
    fail("dist/normalise-reference.zip is missing. Run scripts/bash/01-package-function.sh")

# 6. design consistency --------------------------------------------------------------------------------
print("6. Design consistency (locals.tf)")
if not L:
    print("  SKIP  python-hcl2 not installed (pip install python-hcl2)")
else:
    before = len(problems)

    def need(kind, name, where, pool):
        if name not in pool:
            fail(f"{where}: {kind} '{name}' is not defined")

    groups, divisions, roles = set(L["groups"]), set(L["divisions"]), set(L["roles"])
    wraps, flows, sgs = set(L["wrapup_codes"]), set(L["flows"]), set(L["schedule_groups"])
    for qn, q in L["queues"].items():
        need("division", q["division"], f"queue {qn}", divisions)
        need("group", q["base_group"], f"queue {qn}", groups)
        for o in q["overflow"]:
            need("group", o["group"], f"queue {qn} ring", groups)
        for o in q.get("surge", []):
            need("group", o["group"], f"queue {qn} surge", groups)
        for w in q["wrapup_codes"]:
            need("wrap-up code", w, f"queue {qn}", wraps)
        if len(q["overflow"]) > 4:
            fail(f"queue {qn}: more than 4 overflow entries (Genesys allows 6 rings: base + overflow + the final everyone ring)")
        if q.get("surge") and not q["overflow"]:
            fail(f"queue {qn}: surge rules need at least one overflow ring")
        if len(q.get("surge", [])) > 5:
            fail(f"queue {qn}: more than 5 surge rules")
    for g, gr in L["group_roles"].items():
        need("group", g, "group_roles", groups)
        for r in gr["roles"]:
            need("role", r, f"group_roles {g}", roles)
        for d in gr.get("exclude_divisions", []):
            need("division", d, f"group_roles {g}", divisions)
    need("role", L["integration_role_name"], "integration_role_name", roles)
    for fk, fv in L["flows"].items():
        if not (flows_dir / fv["file"]).exists():
            fail(f"flow {fk}: file {fv['file']} does not exist")
    need("flow", "message", "flows", flows)
    need("flow", L["surge_flow"], "surge_flow", flows)
    need("flow", L["event_workflow"], "event_workflow", flows)
    overridden = 0
    for ln, ln_v in L["lines"].items():
        for key in ("open_flow", "closed_flow", "holiday_flow"):
            if ln_v.get(key):
                need("flow", ln_v[key], f"line {ln}", flows)
        need("schedule group", ln_v["schedule_group"], f"line {ln}", sgs)
        overridden += 1 if ln_v.get("surge_override") else 0
        for d in ln_v["dnis"]:
            if not d.startswith("+6135550"):
                fail(f"line {ln}: {d} is not in the drama range")
    if overridden == 0:
        fail("no line is overridden by the surge switch")
    for sg, sgv in L["schedule_groups"].items():
        for o in sgv["open"]:
            need("open schedule", o, f"schedule group {sg}", set(L["open_schedules"]))
    for k in L["recorded_queue_keys"]:
        need("queue", k, "recorded_queue_keys", set(L["queues"]))
    if len(L["ai"]["guardrails"]) < 5:
        fail("fewer than 5 AI guardrail rules")
    if L["ai"]["faq"] == {}:
        fail("empty knowledge base")
    if len(problems) == before:
        ok(f"{len(L['queues'])} queues, {len(L['lines'])} lines, {len(L['flows'])} flows, {len(L['groups'])} groups all line up")

print()
if problems:
    print(f"{len(problems)} problem(s). Fix them before committing.")
    sys.exit(1)
print("All checks passed.")
