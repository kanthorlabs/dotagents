from dataclasses import dataclass


@dataclass
class TenantConfig:
    id: str
    retention_days: int

    def validate(self):
        if self.retention_days < 0:
            raise ValueError("retention_days must be >= 0")
