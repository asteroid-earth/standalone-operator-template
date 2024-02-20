# Teleport Kubernetes Operator Template

This repo is a template repo you can fork to get a head start on using Terraform to manage
the Teleport [Standalone Kubernetes Operator](https://goteleport.com/docs/management/dynamic-resources/teleport-operator-standalone/).

## Prerequisites

You will need to install:
* [Teleport](https://goteleport.com/docs/installation/)
* [Terraform](https://developer.hashicorp.com/terraform/install)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Setting up

To run the Terraform, you will need to have an appropriate role existing in your Teleport cluster.
You can do add the role with the following steps:
* Log in as an admin user: `$ tsh login --proxy=<your proxy url> --user=<your username/email>`
* Create the role: `$ tctl create ./terraform/terraform.yaml`

Now that you have a role, open up a new terminal window where we can start a bot that will run
on your machine that Terraform can use to authenticate with Teleport. In that terminal `$ cd terraform`
to get into the terraform directory, and run `$ sudo create_and_start_bot.sh`. The bot will now be running
and you can go back to your first terminal window.

Note: This is necessary because on a local workstation our bot has to join via a token. In a production
environment, you should move to running the Terraform commands on a machine in GitHub Actions/AWS/etc
that can authenticate with Teleport by inherent properties. An example of setting up GitHub Actions
to run Terraform can be found in the `./github` directory of this repo. It includes Terraform to setup
the necessary token and bot resources, and an example Actions workflow file.

## Installing the Operator

In the Terraform directory, run `$ terraform init` to do the necessary prep for running an apply command.
To apply the terraform, run
```shell
$ terraform apply -var="kubernetes_context=<context name for your K8s cluster from kube config>" \
-var="teleport_addr=<domain of your proxy>" \
-var="jwks=$(kubectl get --raw /openid/v1/jwks)"

```

The last variable flag will dynamically retrieve the JWKS from your K8s cluster to add as
trusted certificates to Teleport.

The Terraform code creates the following resources in Teleport:
* Role for the operator
* Token using the cluster JWKS
* Bot for the Operator to act as

And the following resoruces in your K8s cluster:
* Namespace to install the Helm chart in
* Helm chart that creates a deployment of an Operator pod.

To make sure the Operator is installed correctly, run `$ kubectl get pods -n teleport-iac`;
you should see one pod with the status `Running`.

## Creating Resources

Now that the operator is in your cluster, you can add resource manifests to Kubernetes and the Operator
will create them in Teleport.

Try this now by running `$ kubectl apply -f k8s/user.yaml`. You can now check the UI of your Teleport
instance, or run `$ tctl users ls | grep alice` and you should see the new user. You can remove
the user by running `$ kubectl delete -f k8s/user.yaml`.

## Wrapping Up

Hopefully this repo is helpful! If you need help or have any questions, you can [join our
Community Slack](https://goteleport.com/community-slack/) and reach out!
