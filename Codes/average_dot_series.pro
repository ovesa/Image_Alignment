; create averaged target SAV files

date = '12042018'
wvl = '4170'
output_path = "/home/users/ovesa/Swirl_dataset/Calibrations/" + date + "/"


dot_file = output_path + date + ".ROSA." + wvl + ".Dot.Grid.Images.fit"
;target_file = output_path + date + ".ROSA.3500.Target.Images.fit"
;target_file = output_path + date + ".ROSA.4170.Target.Images.fit"
;target_file = output_path + date + ".ROSA.ZYLA.Target.Images.fit"

print, dot_file

fits_open, dot_file, fcb
max_exten = fcb.nextend
fits_close, fcb



dot_series = FLTARR(1004,1002,max_exten)
seqstart=0
seqend = max_exten - 1

FOR ext=0, seqend DO BEGIN & dot_series[*,*,ext] = readfits(dot_file, exten=ext+1, /SILENT) & print, ext & ENDFOR

dot_ave = FLTARR(1004,1002)

dot_ave[*,*] = MEAN(dot_series, dimension=3)


SAVE, dot_ave, FILENAME = output_path +  "Average.Series." + wvl + ".Dot.Grid." + date + ".sav"



tvscl, dot_ave

output = '/home/users/ovesa/Swirl_dataset/Calibrations/'
dot_ave = readfits(output + '04112018.Zyla.Average.DotGrid.Image.fits', exten=0)
SAVE, dot_ave, FILENAME = output + "Average.Series.ZYLA.Dot.Grid.04112018.sav"


output = '/home/users/ovesa/Swirl_dataset/Calibrations/'
line_ave = readfits(output + '11102017.Zyla.Average.LineGrid.Image.fits', exten=0)
SAVE, line_ave, FILENAME = output + "Average.Series.ZYLA.Line.Grid.11102017.sav"

output = '/home/users/ovesa/Swirl_dataset/Calibrations/'
dot_ave = readfits(output + '12042018.Zyla.185741.Average.DotGrid.Image.fits', exten=0)
SAVE, dot_ave, FILENAME = output + "Average.Series.ZYLA.Dot.Grid.12042018.sav"
