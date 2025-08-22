variable "team" {
  default = "platform"
}

variable "environment" {
  default = "global"
}

variable "project" {
  default = "QDP"
}

locals {
  compulsory_tags = {
    Name        = "${var.team}-${var.environment}-${var.project}"
    Team        = var.team
    Project     = var.project
    Environment = var.environment
    Automation  = "terraform"
  }
  org_access_role_name = "OrganizationAccountAccessRole"
}

data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

variable "tenants" {
  type = list(
    object({
      name  = string,
      email = string,
      fqdn  = string,
      #      fqdn_zone_id = string,
      records = list(object({
        type = string, hostname = string, values = list(string), ttl = string
      })),
      github_maintainers  = list(string),
      github_members      = list(string),
      github_repositories = list(string),
      ecr_repositories    = list(string)
  }))
  default = [
    {
      name    = "SquadEx"
      email   = "squadex@quarphix.co.za",
      fqdn    = "squadex.net"
      records = [],
      github_maintainers = ["edgarkanyes", "ctumwebaze", "makiika", "KaraboRamalepe", "ThatoRammutla",
      "sandilenkosie", "Riecky31", "Lerato00", "ZMulula", "Rethabilelebese", "TshepoSiphoSithole"],
      github_members = ["Rito0"],
      github_repositories = [
        "squadex-registration-provider", "squadex-login-provider", "squadex-api", "squadex-web-app",
        "squadex-pnet-spike", "squadex-acceptance-tests"
      ],
      ecr_repositories = ["api", "skillscleanup", "webapp", "login-provider", "registration-provider", "open-webapp",
        "recruiter-webapp", "employer-webapp", "candidate-webapp", "backoffice-webapp"
      ]
    },
    {
      name                = "Fundanathi"
      email               = "fundanathi-platform@quarphix.co.za",
      fqdn                = "fundanathi.live"
      records             = [],
      github_maintainers  = ["edgarkanyes", "ctumwebaze", "makiika"],
      github_members      = ["Rito0"],
      github_repositories = [],
      ecr_repositories    = ["v1-portal", "v1-lms"]
    }
  ]
}
