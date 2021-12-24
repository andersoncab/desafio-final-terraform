
variable "sg_ports" {
    type = list(number)
    description = "Lista das portas liberadas"
    default = [80, 443, 22] 
}
