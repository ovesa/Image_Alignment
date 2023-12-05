; create averaged target SAV files

; For ROSA target Images 

date = '12042018'
wvl = '4170'
output_path = "/home/users/ovesa/Swirl_dataset/Calibrations/" + date + "/"

target_file = output_path + date + ".ROSA." + wvl + ".Target.Images.fit"
;target_file = output_path + date + ".ROSA.3500.Target.Images.fit"
;target_file = output_path + date + ".ROSA.4170.Target.Images.fit"
;target_file = output_path + date + ".ROSA.ZYLA.Target.Images.fit"

print, target_file

fits_open, target_file, fcb
max_exten = fcb.nextend
fits_close, fcb



target_series = FLTARR(1004,1002,max_exten)
seqstart=0
seqend = max_exten - 1

FOR ext=0, seqend DO BEGIN & target_series[*,*,ext] = readfits(target_file, exten=ext+1, /SILENT) & print, ext & ENDFOR

target_ave = FLTARR(1004,1002)

target_ave[*,*] = MEAN(target_series, dimension=3)


SAVE, target_ave, FILENAME = output_path +  "Average.Series." + wvl + ".Target." + date + ".sav"



tvscl, target_ave

; For IBIS target Images

date = '12042018'
wvl = 'IBIS'
output_path = "/home/users/ovesa/Swirl_dataset/Calibrations/" + date + "/"

target_file = output_path + "s000.TargetImages.fits"
;target_file = output_path + date + ".ROSA.3500.Target.Images.fit"
;target_file = output_path + date + ".ROSA.4170.Target.Images.fit"
;target_file = output_path + date + ".ROSA.ZYLA.Target.Images.fit"

print, target_file

fits_open, target_file, fcb
max_exten = fcb.nextend
fits_close, fcb


fits_open, target_file, fcb
max_exten = fcb.nextend
fits_close, fcb



target_series = FLTARR(1000,1000,max_exten)
seqstart=0
seqend = max_exten - 1

FOR ext=0, seqend DO BEGIN & target_series[*,*,ext] = readfits(target_file, exten=ext+1, /SILENT) & print, ext & ENDFOR

target_ave = FLTARR(1000,1000)

target_ave[*,*] = MEAN(target_series, dimension=3)


SAVE, target_ave, FILENAME = output_path +  "Average.Series." + wvl + ".Target." + date + ".sav"



tvscl, target_ave
