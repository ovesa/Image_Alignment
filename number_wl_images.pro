; Find the number of whitelight files total for given series
; have to be in the current day working directory

FUNCTION number_wl_images, date_string, series1, series2
;
; NAME:
;	number_wl_images
;
; PURPOSE:
;
;	number = number_wl_images(date_string, series)
;
; INPUTS:
; 	date_string  = name of the day folder
;	series 	     = wl series folder for which to count
;
; WRITTEN BY
;	Oana Vesa 12/05/2020

path_input    = '/run/media/ovesa/Elements1/t1144/'
date_input    = date_string
full_path_input     = path_input + date_string + '/whitelight/ScienceObservation/'
series_input  = series1 + '/'
series_input2 = series2 + '/'


wl_files_series1 = file_search(full_path_input + series_input, '*.fits',count=num_series1)
wl_files_series2 = file_search(full_path_input + series_input2, '*.fits',count=num_series2) 

; If there are two series, they are joined together
all_wl_data_files = [wl_files_series1, wl_files_series2] 

print, all_wl_data_files
print, 'Number of files', num_series1+ num_series2
Print, 'Number of files', n_elements(all_wl_data_files)
END
