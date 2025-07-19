import subprocess
import secrets
import string
import tempfile
from pathlib import Path
import argparse


class OnePasswordProvisioner:
    def __init__(
        self,
        user: str,
        service: str,
        password_length: int = 32,
    ):
        self.vault = "mistiop"
        self.user = user
        self.service = service
        self.password_length = password_length
        self.key_name = f"{service}_{user}_key"

    def signin(self):
        print("🔐 Signing into 1Password...")
        subprocess.run(["op", "signin"], check=True)

    def generate_password(self) -> str:
        alphabet = string.ascii_letters + string.digits + "!-.*+="
        return "".join(secrets.choice(alphabet) for _ in range(self.password_length))

    def generate_ssh_keypair(self, key_path: Path):
        subprocess.run(
            [
                "ssh-keygen",
                "-t",
                "rsa",
                "-f",
                str(key_path),
                "-C",
                f"{self.user}@automated",
                "-N",
                "",
            ],
            check=True,
        )
        return key_path, key_path.with_suffix(".pub")

    def create_op_item(self, title: str, fields: dict, category: str = "Secure Note"):
        args = ["op", "item", "create", "--vault", self.vault, "--category", category]
        for key, value in fields.items():
            args.append(f"{key}={value}")
        args += ["--title", title]
        subprocess.run(args, check=True)
        print(f"✅ Created item '{title}' in vault '{self.vault}'")

    def run(self):
        self.signin()

        print("🔐 Generating secure password...")
        password = self.generate_password()

        print("🔐 Generating SSH keypair...")
        with tempfile.TemporaryDirectory() as tmpdir:
            key_path = Path(tmpdir) / self.key_name
            privkey_path, pubkey_path = self.generate_ssh_keypair(key_path)

            private_key = privkey_path.read_text().strip()
            public_key = pubkey_path.read_text().strip()

        print("📦 Storing credentials in 1Password...")

        self.create_op_item(
            self.service,
            {
                "username": self.user,
                "password": password,
                "public key": public_key,
                "private key": private_key,
            },
            category="login",
        )

        print("\n🎉 Done! Your secrets are stored in 1Password.")
        print(f"🗂 Vault Item Title: {self.service}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Provision SSH and password secrets to 1Password."
    )
    parser.add_argument(
        "--user", required=True, help="Username to provision (e.g., deployer)"
    )
    parser.add_argument(
        "--service", required=True, help="Service name (e.g., ubuntu, web, postgres)"
    )

    args = parser.parse_args()
    provisioner = OnePasswordProvisioner(user=args.user, service=args.service)
    provisioner.run()
