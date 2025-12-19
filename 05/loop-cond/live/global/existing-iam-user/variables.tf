##### for expression - list input #####
# variable "user_names" {
#   default = ["red", "blue", "green"]
# }

# output "upper_user_names" {
#   value = [for name in var.var.user_names: upper(name) if length(name) < 4]
# }

##### for expression - map input #####
variable "hero_thousand_faces" {
  description = "map"
  type        = map(string)
  default     = {
    neo      = "hero"            # -> neo is the hero
    trinity  = "love interest"   # -> trinity is th love interst
    morpheus = "mentor"          # -> morpheus is the mentor
  }
}

# output은 대부분 list나 튜플의 형태
output "bios"{
  value = [for name,role in var.hero_thousand_faces: "${name} is the ${role}"]
}

