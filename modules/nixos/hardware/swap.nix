{ ... }:
{
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024;
    }
  ];

  boot.kernel.sysctl."vm.swappiness" = 10;
}
