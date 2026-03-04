# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - keiwop <keiwop.dev@gmail.com>

{ config, pkgs, ... }:

let
  local_config = import ./local_config.nix;
  host_name = local_config.host_name or (abort "undefined host_name in local_config.nix");

  apps = pkgs.callPackage ./apps.nix {};
  machine_config = import ./machines/${host_name}/${host_name}.nix { inherit apps; };

  user_name = machine_config.user_name or (abort "undefined user_name in ${host_name}.nix");
  secrets = import ./machines/${host_name}/secrets.nix;
  builder_addr = machine_config.builder_addr;

  paths = pkgs.callPackage ./paths.nix { inherit user_name machine_config; };

  # Custom packages
  link_config_files = pkgs.callPackage ./scripts/link_config_files.nix { inherit (paths) linked_paths; };
  create_direnv = pkgs.callPackage ./scripts/create_direnv.nix { inherit (paths) nixos_path; };
in
{
  #############################################################################
  ### Imports #################################################################
  #############################################################################

  imports = [
    /etc/nixos/hardware-configuration.nix
    machine_config.module
    # (import ./app_config/syncthing.nix { user_name = user_name; host_name = host_name; cfg_path = paths.nixos_path; secrets = secrets; })
    # (import ./app_config/kwin.nix)
    # (import ./remote_build.nix { user_name = user_name; builder_addr = builder_addr; pkgs = pkgs; })
    # (import "${home-manager}/nixos")
  ];


  #############################################################################
  ### Boot ####################################################################
  #############################################################################
  
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" "data=ordered" ];
  
  swapDevices = [
    {
      device = "/swap";
      size = 1024;
    }
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "mitigations=off" ];


  #############################################################################
  ### System packages #########################################################
  #############################################################################

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    link_config_files
    create_direnv
  ];

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
  };

  programs.direnv.enable = true;

  environment.etc."direnv/direnv.toml".text = ''
    [global]
    hide_env_diff = true
  '';

  programs.firefox.enable = true;


  #############################################################################
  ### User configuration ######################################################
  #############################################################################

  users.mutableUsers = false;

  users.users.root = {
    hashedPassword = "${secrets.root_password}";
    shell = pkgs.zsh;
  };

  users.users.${user_name} = {
    isNormalUser = true;
    hashedPassword = "${secrets.user_password}";
    shell = pkgs.zsh;
    description = "${user_name}";
    group = "${user_name}";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  users.groups.${user_name}.gid = 1000;

  security.sudo.wheelNeedsPassword = false;

  # home-manager.users.${user_name} = import ./home.nix { inherit pkgs config; };

  system.activationScripts.copy_ssh_keys = ''
    SSH_DIR="/home/${user_name}/.ssh"
    if [ ! -e $SSH_DIR/id_ed25519 ]; then
      mkdir -p $SSH_DIR
      cp "${paths.nix_config_path}/machines/${host_name}/ssh/id_ed25519"* $SSH_DIR/
      chmod 600 $SSH_DIR/id_ed25519
      chown -R "${user_name}:${user_name}" $SSH_DIR
    fi
  '';


  #############################################################################
  ### Services ################################################################
  #############################################################################

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
    };
    extraConfig = ''
      Match Address 192.168.1.0/24
        PasswordAuthentication yes
      Match all
    '';
  };

  # Custom service that links the config files at boot time
  systemd.services."${user_name}-link-config" = {
    enable = true;
    description = "Links config files at boot time with stow";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin";
      ExecStart = "${link_config_files}/bin/link_config_files";
    };
  };

  # services.udev.packages = [ minichlink ];


  #############################################################################
  ### Networking ##############################################################
  #############################################################################

  networking.hostName = "${host_name}";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.networkmanager.enable = true;

  # networking.firewall.allowedTCPPorts = [ 22 8384 22000 ];
  # networking.firewall.allowedUDPPorts = [ 22000 21027 ];
  networking.firewall.enable = false;


  #############################################################################
  ### Locale ##################################################################
  #############################################################################

  # time.timeZone = "Europe/Paris";

  # console.keyMap = "fr";

  # i18n.defaultLocale = "en_US.UTF-8";

  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "fr_FR.UTF-8";
  #   LC_IDENTIFICATION = "fr_FR.UTF-8";
  #   LC_MEASUREMENT = "fr_FR.UTF-8";
  #   LC_MONETARY = "fr_FR.UTF-8";
  #   LC_NAME = "fr_FR.UTF-8";
  #   LC_NUMERIC = "fr_FR.UTF-8";
  #   LC_PAPER = "fr_FR.UTF-8";
  #   LC_TELEPHONE = "fr_FR.UTF-8";
  #   LC_TIME = "fr_FR.UTF-8";
  # };


  #############################################################################
  ### Window Manager ##########################################################
  #############################################################################
  
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "${user_name}";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable touchpad support (enabled by default in most desktopManager).
  services.libinput.enable = true;

  # Don't install all plasma6 packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    okular
  ];

  programs.hyprland.enable = true;
  programs.dconf.enable = true;

  # TODO
  # programs.dconf.profiles.user.databases = [ {
  #   settings."org/gnome/desktop/interface" = {
  #     gtk-theme = "Adwaita";
  #     icon-theme = "Flat-Remix";
  #     font-name = "Noto Sans Medium 11";
  #     document-font-name = "Noto Sans Medium 11";
  #     monospace-font-name = "Noto Sans Mono Medium 11";
  #   };
  # }];

  #############################################################################
  ### Fun stuff ###############################################################
  #############################################################################

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #media-session.enable = true;
  };


  #############################################################################
  ### Misc ####################################################################
  #############################################################################

  services.thermald.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
