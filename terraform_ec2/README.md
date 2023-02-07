digraph {
compound = "true"
newrank = "true"
subgraph "root" {
"[root] aws_instance.terraform (expand)" [label = "aws_instance.terraform", shape = "box"]  
 "[root] aws_security_group.instance_security_group (expand)" [label = "aws_security_group.instance_security_group", shape = "box"]
"[root] provider[\"registry.terraform.io/hashicorp/aws\"]" [label = "provider[\"registry.terraform.io/hashicorp/aws\"]", shape = "diamond"]
"[root] aws_instance.terraform (expand)" -> "[root] aws_security_group.instance_security_group (expand)"
"[root] aws_security_group.instance_security_group (expand)" -> "[root] provider[\"registry.terraform.io/hashicorp/aws\"]"
"[root] provider[\"registry.terraform.io/hashicorp/aws\"] (close)" -> "[root] aws_instance.terraform (expand)"
"[root] root" -> "[root] provider[\"registry.terraform.io/hashicorp/aws\"] (close)"
}
}

---

Outputs:
public_ip = "52.31.61.244"
