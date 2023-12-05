; IDL Code to obtain sequence cadence
; i.e. how long it takes to go through the entire sequences of spectral lines
; this code is for two series available

; load in the spectral narrowband images from the available series
 fname_series1 = file_search('20190426_142453/s*.fits',count=s1)
 fname_series2 = file_search('20190426_152400/s*.fits',count=s2)
 
 ; if there are more than one series, you need to join them
 join_time = strarr(s1 +s2)
 
 ; for loops that go through each series and through each fits file and draws out the start time of the observations
 
for nn=0,s1-1 do begin & sci = readfits(fname_series1[nn],exten=1,hdr,/silent) & join_time[nn] = sxpar(hdr,'DATE-OBS') & endfor 

for mm=0,s2-1 do begin & sci2 = readfits( fname_series2[mm],exten=1,hdr2,/silent) & join_time[mm + s1] = sxpar(hdr2,'DATE-OBS')   & endfor 
 
; converting the times to julian date to make things easier
join_time = fits_date_convert(join_time)
delt = fltarr(s1+s2)
for nn=1,n_elements(delt)-1 do begin & delt[nn-1] = join_time[nn] -join_time[nn-1] & endfor
delt = delt*86400. ; converting to seconds

; plotting to results to an eps file
set_plot, 'ps'
!p.font=0
aspect_ratio=1.5 ;rectangle
device,/encapsulated,/helvetica, file = '26Apr_Sequence_Cadence.eps', /COLOR
plot, delt,/yn, TITLE = 'Sequence Cadence', YTITLE=' Time [sec]', YRANGE=[10,60]

; plotting the median line that gives us the sequence cadence
loadct, 34
HOR,  median(delt), color = 250, Thickness=2
xyouts, 400,20,'Median Time: ' + string(median(delt)) ,color=250
loadct,0
device, /close
set_plot, 'x'
!p.font=-1

print, median(delt)


