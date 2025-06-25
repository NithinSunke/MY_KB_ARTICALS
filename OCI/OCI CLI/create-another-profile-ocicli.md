# Create Multiple Oci Cli profiles

To add your **Disaster Recovery (DR) region – Riyadh** to your **OCI CLI config**, you don’t need to rerun `oci setup config`. Instead, just **edit your existing `config` file** to include **multiple profiles** or **switch the region when needed**.

---

## ✅ Option 1: **Use Multiple Profiles (Recommended)**

Create two profiles: one for **Jeddah** (primary) and one for **Riyadh** (DR).

### 🔧 Edit the config file:

```powershell
notepad $HOME\.oci\config
```

Update it like this:

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaaxxxxx
fingerprint=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
key_file=C:\Users\YourUsername\.oci\oci_api_key.pem
tenancy=ocid1.tenancy.oc1..aaaaaaaaxxxxx
region=me-jeddah-1

[DR]
user=ocid1.user.oc1..aaaaaaaaxxxxx
fingerprint=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
key_file=C:\Users\YourUsername\.oci\oci_api_key.pem
tenancy=ocid1.tenancy.oc1..aaaaaaaaxxxxx
region=me-riyadh-1
```

> You can reuse the same user, key, and tenancy OCIDs. Only `region` differs.

---

### 🧪 To use the DR region (Riyadh), run:

```bash
oci os ns get --profile DR
```

Or, keep using `--profile DEFAULT` for Jeddah:

```bash
oci os ns get
```

---

## ✅ Option 2: **Temporarily Override the Region in CLI**

If you want to use just one profile and override the region when needed:

```bash
oci os ns get --region me-riyadh-1
```

But this is manual and not ideal for scripting.

---

## ✅ Option 3: **Set Region with Environment Variable**

You can set the region before a command using:

```bash
$env:OCI_CLI_REGION = "me-riyadh-1"
oci os ns get
```

Then reset it:

```bash
Remove-Item Env:OCI_CLI_REGION
```

---
