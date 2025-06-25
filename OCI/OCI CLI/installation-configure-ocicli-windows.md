### ✅ **Step 1: Install Python (if not installed)**

OCI CLI requires Python 3.6+.

1. Download Python from: [https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/)
2. During installation, check ✅ **"Add Python to PATH"**, then complete the installation.

---

### ✅ **Step 2: Install OCI CLI using the installer script**

1. **Open PowerShell as Administrator**
2. Run the installation script:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-WebRequest -Uri https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.ps1 -OutFile install.ps1
.\install.ps1
```

3. Follow the prompts. By default, it installs to:
   `C:\Users\<YourUser>\lib\oracle-cli`

---

### ✅ **Step 3: Add OCI CLI to PATH**

If not automatically added, do this:

1. Open System Properties → Environment Variables.
2. Under "User variables" → Edit `Path`
3. Add:
   `C:\Users\<YourUser>\bin\oci.exe`

---

### ✅ **Step 4: Configure OCI CLI**

Once installed, configure it with your OCI tenancy and user details.

Run in PowerShell:

```bash
oci setup config
```

You’ll be prompted for:

| Prompt                  | Value to Enter                                         |
| ----------------------- | ------------------------------------------------------ |
| **Location for config** | Press Enter for default (`~\.oci\config`)              |
| **Tenancy OCID**        | Get from OCI console (Identity → Tenancies)            |
| **User OCID**           | From OCI console (Identity → Users)                    |
| **Compartment OCID**    | Optional now; can be used in commands                  |
| **Region**              | Use: `me-jeddah-1` for Jeddah, or `me-riyadh-1` for DR |
| **Output format**       | `json` is recommended                                  |

---

### ✅ **Step 5: Upload API Public Key to OCI Console**

After config, your public key is in:

```plaintext
C:\Users\<YourUser>\.oci\oci_api_key_public.pem
```

Upload it in:
**OCI Console → Identity → Users → Your User → API Keys → Add API Key → Paste Public Key**

---

### ✅ **Step 6: Test**

Run a test command to confirm:

```bash
oci os ns get
```

If successful, it will return your namespace.

---

### Need Help with OCIDs?

You can find all necessary OCIDs in the **OCI Console**:

* Tenancy: Identity → Tenancies
* User: Identity → Users
* Compartment: Identity → Compartments

---
