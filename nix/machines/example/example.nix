# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C): 2025 - 2026 - keiwop <keiwop.dev@gmail.com>

{ apps }:


let
  user_name = "keiwop";
  builder_addr = "arch-laptop";
  secrets = import ./secrets.nix;
in

{
  inherit user_name builder_addr;

  linked_paths = [
    { name="esphome"; source="/_/etc/docker/esphome"; target="/_/dkr/esphome"; user="${user_name}"; }
    { name="ha_dev"; source="/_/etc/docker/ha_dev"; target="/_/dkr/ha_dev"; user="${user_name}"; }
  ];

  module = { config, pkgs, ... }: {
    imports = [
      (import ./syncthing/syncthing.nix { user_name = user_name; secrets = secrets; })
    ];
  
    #############################################################################
    ### Apps ####################################################################
    #############################################################################

    environment.systemPackages = with pkgs;
      apps.core
      ++ apps.dev
      ++ apps.gui
      ++ apps.media
      ++ apps.misc

      ++[
      apps.custom.termm
      apps.custom.kwin_focus_app
      apps.custom.minichlink
      apps.custom.riscv32ec_toolchain
      apps.custom.jellyfin_desktop

      siril
      zed-editor
    ];

    environment.sessionVariables = {
      KICAD9_SYMBOL_DIR = "/_/fun/kicad/symbols";
      KICAD9_FOOTPRINT_DIR = "/_/fun/kicad/footprints";
      KICAD9_3DMODEL_DIR = "/_/fun/kicad/3dmodels";
      KICAD9_3RD_PARTY = "/_/fun/kicad/3rdparty";
      KICAD9_TEMPLATE_DIR = "/_/fun/kicad/template";
      KICAD_USER_TEMPLATE_DIR = "/_/fun/kicad/template_user";
    };


    #############################################################################
    ### Services ################################################################
    #############################################################################

    services.kmscon = {
      enable = true;
      useXkbConfig = true;
      autologinUser = "keiwop";
    };

    services.displayManager.defaultSession = "plasmax11";

    users.users.${user_name}.extraGroups = [ "dialout" "docker" ];
    services.udev.packages = [ apps.custom.minichlink ];
    services.udev.extraRules = ''
      # CH341a programmer
      SUBSYSTEM=="usb", ATTR{idVendor}=="1a86", ATTR{idProduct}=="5512", MODE="0660", GROUP="wheel"
    '';

    virtualisation.docker = {
      enable = true;
    };

    services.printing.drivers = [ pkgs.samsung-unified-linux-driver ];


    #############################################################################
    ### Locale ##################################################################
    #############################################################################

    time.timeZone = "Europe/Paris";

    console.keyMap = "fr";

    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };

    services.xserver.xkb = {
      layout = "fr";
      variant = "azerty";
      options = "ctrl:nocaps";  # Remap CapsLock to Control
    };


    #############################################################################
    ### Laptop ##################################################################
    #############################################################################

    powerManagement.powertop.enable = true;


    #############################################################################
    ### HW Specific #############################################################
    #############################################################################

    # Bodge to get the battery estimation working again after suspend
    systemd.services."fix-battery-module" = {
      enable = true;
      description = "Reloads the battery module after suspend";
      wantedBy = [ "suspend.target" ];
      after = [ "suspend.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin";
        ExecStart = "${pkgs.writeShellScript "fix_battery_module" ''
          #! /bin/sh
          modprobe -r battery
          modprobe battery
        ''}";
      };
    };

    # Don't touch unless you go read about it
    system.stateVersion = "25.11";
  };
}
