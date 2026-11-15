# Intro to Ansible


* What is Ansible?
  * configuration management tool
  * best at configuring software
  * command-based not GUI
  * Red Hat leads development, guaranteeing quality open-source code
  * Application is written in Python
  * Started off with a few core modules for managing/configuring Linux servers
  * Can be used now with almost any system


* How does Ansible work?
  * It's like having recipes that my robot (Ansible) follows to setup/configure software on
  * I write the configuration files in YAML (the recipes) - called "playbooks"
  * The robot (Ansible) can login via SSH and then configure the software on a device
  * "Ansible Control Node" (a controller computer/host) to tell the Target Nodes (the machines/hosts/servers that need configuring) what to do
  * "Playbooks" and "Inventory" (list of Target Nodes)
  * Unique attributes:
    * Module-based architecture
    * Agentless
      * No need to install Ansible on Target Nodes
      * Instead, Ansible controller will SSH into Target Nodes
      * A Python intepreter is required on Linux Target Nodes
