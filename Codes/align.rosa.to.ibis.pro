; text files contain the julian dates for a particular wavelength through time
; For IBIS, the time stamps just correspond to the first Ca scan in the sequence.
ROSA_times_text_file = '/home/users/ovesa/Swirl_dataset/Times/11.27.2018.zyla.times.txt'
IBIS_times_text_file = '/home/users/ovesa/Swirl_dataset/Times/11.27.2018.ca8542.times.txt'


; obtain number of extensions (i.e files lines)
ROSA_ext = FILE_LINES(ROSA_times_text_file)
IBIS_ext = FILE_LINES(IBIS_times_text_file)

; read in the julian dates and store in a string array for easier access
OPENR, lun, ROSA_times_text_file, /get_lun
ROSA_times = DBLARR(ROSA_ext)
READF, lun, ROSA_times
FREE_LUN, lun

OPENR, lun, IBIS_times_text_file, /get_lun
IBIS_times = DBLARR(IBIS_ext)
READF, lun, IBIS_times
FREE_LUN, lun


; directory where IBIS files are stored
; IBIS files are SAV files
; IBIS images already all ROTATE(arr, 7)
IBIS_directory = '/home/users/ovesa/Swirl_dataset/IBIS2/'
nb = file_search(IBIS_directory, '6563_nb*sav')


; directory where ROSA FITS files are stored
ROSA_directory = '/boomerang-data/ovesa/swirls_data/11272018/'
chosen_ROSA_wvlnth = ROSA_directory + '11272018.ZYLA.aligned.fits'

; sequence information
; aligning ROSA to IBIS

seqstart =  0
seqend = ROSA_ext - 1

; plate scales
; target plate_scales
IBIS_plate_scale = 0.097 ; arcsec/pix
ROSA_plate_scale = 0.06 ; arcsec/pix  0.17?
ZYLA_plate_scale = 0.083 ; arcsec/pix  0.17?

; initial plate scales - derived from dot grids
initial_gband_ps = [0.0605,0.0578]
initial_cak_ps = [0.059,0.059]
initial_4170_ps = [0.0601,0.0576]
initial_3500_ps = [ 0.06129, 0.05994]s

; rotation direction to match IBIS (ROTATE 7)
ROSA_rot_gband = 6
ROSA_rot_3500 = 6
ROSA_rot_4170 = 6
ROSA_rot_cak = 3
ZYLA_rot = 1


; rotations in degrees to apply to the images
; correct for minor rotations between the ROSA images and to IBIS
;init_rot_gband = 1.649 ; rotation to match GBAND to Ca II
;second_rot_gband = -0.8 ; rotation to match GBAND to Ca II
;third_rot_gband = 0.8
;fourth_rot_gband = -1
init_rot_cak   = 1.198
init_rot_gband = 0.68
init_rot_4170  = 1.647 ; rotation to match 4170 to GBAND
init_rot_3500  = 0.8
init_rot_zyla  = 1.2 ; rotation to match ZYLA to Ha



; Read in all of the IBIS files at the beginning of the program
; and place them in an array
; IBIS is rotated
IBIS_ims = FLTARR(1000,1000,IBIS_ext, /NOZERO)


; GBAND match with Ca II 8542 frame 1 
; CAK match with Ca II 8542 frame 2
; 4170 - frame 1
; 3500 - frame 1
; Zyla - Ha frame 12

PRINT, 'Reading in IBIS images'
PRINT, 'There are ', IBIS_ext, ' IBIS images'

FOR IBIS_nom = seqstart, IBIS_ext - 1 DO BEGIN
	IF (IBIS_nom MOD 10) EQ 0 THEN PRINT, systime(), IBIS_nom
	RESTORE, nb[IBIS_nom]
	IBIS_ims[*,*,IBIS_nom] = (nbdata[*,*,12])
ENDFOR

PRINT, 'IBIS Images loaded'

; array to hold shifts between ROSA and IBIS
ROSA_to_IBIS_shifts = FLTARR(2, ROSA_ext, /NOZERO)


PRINT, 'Aligning ROSA to IBIS'
PRINT, 'Chosen ROSA File ', chosen_ROSA_wvlnth
PRINT, 'There are ', ROSA_ext, ' ROSA images'

FOR seqnum = seqstart, seqend DO BEGIN
	IF (seqnum MOD 20) EQ 0 THEN PRINT, systime(), seqnum


	; cadence of IBIS in seconds
	; cadence is defined as how long it takes to scan the line to arrive at the same wavelength position
	; goes from line core to line core accounting for load and save time
	IBIS_cadence = 14.4
		
	; grab initial IBIS start time
	IBIS_seq_start = IBIS_times[0]

	
	; Find the corresponding time difference between the ROSA extension and the start of the IBIS sequence in seconds
	; the IBIS sequence time is approximate. I don't account for time of a particular wavelength or frame number
	ROSA_to_IBIS_time_diff = (ROSA_times[seqnum] - IBIS_seq_start)*86400.0
	

	
	; divide the number of seconds by the cadence to find the appropriate index of the IBIS reference image
	IBIS_image_num        = ROUND(ROSA_to_IBIS_time_diff / IBIS_cadence)
	

	; Sometimes the ROSA images start before IBIS. If so, the image number is less than 0 
	; Thus, ROSA is automatically compared with the first IBIS image
	; If the image number is greater than or equal to 244, then 
	; ROSA is compared with the last IBIS image in the sequence which is 243
	IF IBIS_image_num LE 0 THEN IBIS_image_num = 0
	IF IBIS_image_num GE IBIS_ext THEN IBIS_image_num = IBIS_ext - 1
	
	;PRINT, IBIS_image_num
	
	; Read in corresponding IBIS image number
	IBIS_frame_im = IBIS_ims[*,*, IBIS_image_num]
	IBIS_frame_im = IBIS_frame_im - MEAN(IBIS_frame_im)
	
	
	; read in ROSA image
	ROSA_im = readfits(chosen_ROSA_wvlnth, exten=0, nslice=seqnum, /SILENT)
	
	
	; change initial ROSA plate scales to match target ROSA plate scales (0.06 "/pix)
	; I didn't need to do this for Zyla because the Zyla plate was 0.083 "/pix exactly
	; uncomment this part for other ROSA images
	
	;ROSA_to_scale_size= size(ROSA_im)
	;px = ROUND(ROSA_to_scale_size[1]*initial_cak_ps[0]/ROSA_plate_scale)
	;py = ROUND(ROSA_to_scale_size[2]*initial_cak_ps[1]/ROSA_plate_scale)
	;ROSA_im = CONGRID(ROSA_im, px, py, CUBIC=-0.5)
	
	
	
	; properly rotate image to match IBIS
	;ROSA_im = ROT(ROTATE(ROSA_im, ROSA_rot_gband),init_rot_gband, CUBIC=-0.5)
	ROSA_im = ROT(ROTATE(ROSA_im, ZYLA_rot), init_rot_zyla, CUBIC=-0.5)
	ROSA_im = ROSA_im - MEAN(ROSA_im)
	
	; scale IBIS image to the same plate scale as the ROSA data for better alignment
	; ROSA has better resolution than IBIS
	im_size = size(IBIS_frame_im)
	
	; determine number of pixels for scaled image
	; x/y dimension size * current_plate_scale / target_plate_scale
	im_ibis_pix = ROUND(im_size[1:2] * IBIS_plate_scale / ZYLA_plate_scale)
	IBIS_scaled_im  = CONGRID( IBIS_frame_im , im_ibis_pix[0], im_ibis_pix[1], CUBIC=-0.5)
	
	scaled_IBIS_size = size(IBIS_scaled_im, /dim)
	
	; Create a larger array matching the scaled IBIS dimensions to directly align the two sequences
	ROSA_seq = FLTARR(scaled_IBIS_size[0],scaled_IBIS_size[1])
	
	; Random fill value grabbed from the grey outline of the speckled ROSA images
	; Just to not affect the contrast of the image
	ROSA_seq[*,*] = avg(ROSA_im)

	ROSA_size = size(ROSA_im, /dim)
	x0 = (scaled_IBIS_size[0] - ROSA_size[0])/2
	y0 = (scaled_IBIS_size[1] - ROSA_size[1])/2
	
	; Placing ROSA image sequence somewhere in the middle
	; GBAND
	;ROSA_seq[x0:scaled_IBIS_size[0]-x0-2,y0:scaled_IBIS_size[1]-y0-1] = ROSA_im
	
	;CAk
	;ROSA_seq[x0:scaled_IBIS_size[0]-x0-1,y0:scaled_IBIS_size[1]-y0-1] = ROSA_im
	
	;4170
	;ROSA_seq[x0:scaled_IBIS_size[0]-x0-2,y0:scaled_IBIS_size[1]-y0-1] = ROSA_im

	; Zyla 
	ROSA_seq[x0:scaled_IBIS_size[0]-x0-1,y0:scaled_IBIS_size[1]-y0-1] = ROSA_im
	
	
	; calculate shifts between IBIS and ROSA images
	shifts = xyoff(IBIS_scaled_im, ROSA_seq, 756, 756, /quiet)
	ROSA_to_IBIS_shifts[*,seqnum] = shifts
	
	;ROSA_seq[*,*,seqnum] = SHIFT_FRAC(ROSA_seq[*,*,seqnum], (shifts[0]), (shifts[1]),missing=2443)
ENDFOR

SAVE, ROSA_to_IBIS_shifts, FILENAME = '/home/users/ovesa/Swirl_dataset/Shifts/11272018/ROSA2IBIS/11272018.rosa2ibisshifts.zylas.sav'

PRINT, 'Alignment Complete'

END


