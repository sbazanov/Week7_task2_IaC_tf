# Розгортання GKE кластеру за допомогою Terraform.
1. У файлі main.tf використаємо наступний блок коду з відповідного fork-repo ментора:
```hlc
module "gke_cluster" {
  source         = "github.com/sbazanov/tf-google-gke-cluster"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = 2
}
```

2. Файл `vars.tfvars` використовується для зберігання "чутливих змінних" Terraform, які можуть використовуватися в інших файлах Terraform, наприклад main.tf і variables.tf.
  Додамо у файл vars.tfvars настпуні параметри:
```hcl
GOOGLE_PROJECT = "silicon-bivouac-402714"
GOOGLE_REGION = "us-central1-c"
GKE_NUM_NODES  = "2"
```
3. Додамо у файл variables.tf ті самі параметри але без самих їх значень:
```hlc
variable "GOOGLE_PROJECT" {
  type        = string
  default     = ""
  description = "GCP project to use"
}

variable "GOOGLE_REGION" {
  type        = string
  default     = ""
  description = "GCP region to use"
}

variable "GKE_NUM_NODES" {
  type        = number
  default     = ""
  description = "Number of nodes"

```

4. Створимо новий bucket у GCP для зберігання файлу стану Terraform (tfstate).
5. У файлі конфігурації Terraform (main.tf) додайте наступний код, щоб налаштувати бекенд на використання Google Cloud Storage:
```hcl
terraform {
  backend "gcs" {
    bucket = "volume-x"
    prefix = "terraform/state"
  }
}
```
де volume-x - це ім'я бакету, а terraform/state - це шлях до файлу відносно бакету

Також у моєму випадку я використав інший тип інстансів:
t2d-standard-1


6. У GCP терміналі перейдіть до директорії, де знаходяться ваші файли Terraform, і запустіть terraform init, та інші команди перевірки.
```sh
tf init                              
Terraform has been successfully initialized!

tf fmt

tf validate
Success! The configuration is valid.

tf plan -var-file=vars.tfvars
Plan: 3 to add, 0 to change, 0 to destroy.
```

7. Оцінка витрат на інфраструктуру за допомогою Infracost.
```sh 
infracost breakdown --path .  --terraform-var-file vars.tfvars
```
```sh 
Name                                                       Monthly Qty  Unit   Monthly Cost 

                                                                                             
 module.gke_cluster.google_container_cluster.this                                            
 └─ Cluster management fee                                          730  hours        $73.00 
                                                                                             
 module.gke_cluster.google_container_node_pool.this                                          
 ├─ Instance usage (Linux/UNIX, on-demand, t2d-standard-1)        1,460  hours        $61.68 
 └─ Standard provisioned storage (pd-standard)                      200  GB            $8.00 
                                                                                             
 Project total                                                                       $142.68 
 
 
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━┓
┃ Project                                            ┃ Monthly cost ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━┫
┃ sbazanov/Week7_task2_IaC_tf/terraform              ┃ $142.68      ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━┛
```

8. У разі успішності попередніх пунктів розгорнемо інфраструктуру:
```sh
tf apply -var-file=vars.tfvars

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```
9. Перевіримо успішність розгортання.
```sh
terraform show 
```
10. Перевіримо наявність файлу tfstate у бакеті за шляхом: volume-x/terraform/state

![GCP_bucket_for_tfstate](https://github.com/sbazanov/Week7_task2_IaC_tf/assets/96147501/54ad61a5-316a-44f5-84ff-675ec595093c)

Все успішно. Можемо все видаляти:
```sh
tf destroy -var-file=vars.tfvars
Destroy complete! Resources: 3 destroyed.
```
