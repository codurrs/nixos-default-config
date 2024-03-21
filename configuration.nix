# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:


# The following code before the "in" here lets me use unstable/stable for packages, however
# the main channel is the "unstable" channel because it isn't that unstable by default according to me.
# adding the "stable" before packages that are glitchy may help.
let
  stable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-23.11)
    { config = config.nixpkgs.config; };

  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # START OF NVIDIA --------------------------------------------------------------------------------
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"]; # or "nvidiaLegacy470 etc.
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };  
  
  # END OF NVIDIA ------------------------------------------------------------------------
  # Using Xwayland to make flickering in certain apps due to nvidia go away
  programs.xwayland.enable = true;

  # Fixing spotify glitches by enabling native wayland support for most electron apps (Spotify, vscode)
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Fix cursor not showing in Hyprland and Sway
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Detroit";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
 
 # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cody = with pkgs; {
    isNormalUser = true;
    description = "Cody Rouse";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [
    #  thunderbird
    ];
  };
  

  # Home Manager Configuration (Most of/if not all your apps should go in here)  
  home-manager.useGlobalPkgs = true;
  home-manager.users.cody = { pkgs, ... }: {
    home.packages = with pkgs; [
    
    # Applications for sway or hyprland
    swww
    waypaper
    wofi
    kitty
    foot
    alacritty
    swaylock
    swaybg
    dmenu
    wmenu
    pavucontrol

    # Useful for sway compatiibility
    wlroots
    vulkan-validation-layers
    wineWowPackages.waylandFull
    xwaylandvideobridge
    #

    # Unsorted applications
    lazarus
    ghidra
    wireplumber
    rar
    lutris
    protonup-qt
    qbittorrent
    vkd3d-proton
    trilium-desktop
    anki
    cemu-ti
    speedcrunch
    mesa
    xournalpp
    vimPlugins.nvim-web-devicons
    lunarvim
    nerdfonts
    prismlauncher-qt5
    wl-clipboard
    atool 
    httpie
    vim 
    emacs-gtk
    floorp
    calibre
    kate
    steam
    spotify
    gfxtablet
    flameshot
    wget
    
    ];
    programs.bash.enable = true;
    programs.neovim.enable = true;


    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.11";
  };

  xdg.portal.wlr.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    
    # These are global packages, change them to user package if they act up.
    vscode-fhs
    unzip
    git
    gnumake
    python312
    python312Packages.pip
    nodejs_21
    ripgrep
    go
    nerdfonts
    rustup
    gccgo13
    clang-tools_17

  ];

  # Configuring sway
  programs.sway = {
    package = pkgs.swayfx;
    enable = true;
    extraOptions = [ 
      "--unsupported-gpu"
      "--debug"
      "--verbose"
    ];
    extraSessionCommands = ''
      
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      XDG_CURRENT_DESKTOP=sway
      export GDK_BACKEND=wayland
    '';
  };

  # Configuring Hyprland
  programs.hyprland.enable = true;

  # Configuring Weylus
  programs.weylus = {
    enable = true;
    users = [ "cody" ];
    openFirewall = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
