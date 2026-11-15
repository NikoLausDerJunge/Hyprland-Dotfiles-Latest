hl.on("hyprland.start", function () 
  hl.exec_cmd("swaybg -i ~/Wallpapers/mountains-forest-autumn-foggy-peak-grisons-switzerland-5k-3440x1440-1038.jpg -m fill")
  hl.exec_cmd("qs") -- Bar on Top
  hl.exec_cmd("wl-paste --type text --watch cliphist store") -- Clipboard
  hl.exec_cmd("cliphist wipe") -- Clear clipboard history
end)