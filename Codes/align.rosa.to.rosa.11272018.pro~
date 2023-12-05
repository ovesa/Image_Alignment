; text files that contains the julian dates for a particular wavelength
ROSA_times_text_file = '/home/users/ovesa/Swirl_dataset/Times/11.27.2018.4170.times.txt'
reference_times_text_file = '/home/users/ovesa/Swirl_dataset/Times/11.27.2018.gband.times.txt'


; obtain number of extensions (i.e files lines)
ROSA_ext = FILE_LINES(ROSA_times_text_file)
Ref_ROSA_ext = FILE_LINES(reference_times_text_file)

; read in the julian dates and store in a string array for easier access
OPENR, lun, ROSA_times_text_file, /get_lun
ROSA_times = DBLARR(ROSA_ext)
READF, lun, ROSA_times
FREE_LUN, lun

OPENR, lun, reference_times_text_file, /get_lun
ref_times = DBLARR(Ref_ROSA_ext)
READF, lun, ref_times
FREE_LUN, lun


; directory where ROSA FITS files are stored1
ROSA_directory = '/boomerang-data/ovesa/swirls_data/11272018/'
chosen_ROSA_wvlnth = ROSA_directory + '11272018.ROSA.4170.aligned.fits'

ref_im = ROSA_directory + '11272018.GBAND.aligned.final.fits'


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


; Read in a quick image and rotate it to initialize array
tmp_im = readfits(ref_im, exten=0,nslice=0)
tmp_size = size(tmp_im, /DIM)

; set variable to 0 to clear memory
tmp_im = 0

ROSA_seq = FLTARR(tmp_size[0], tmp_size[1],/NoZero)

ROSA_to_GBAND_shifts = FLTARR(2, ROSA_ext)

PRINT, 'Aligning ROSA to GBAND'
PRINT, 'There are ', ROSA_ext, ' images'
FOR seqnum = seqstart, seqend DO BEGIN
	IF (seqnum MOD 20) EQ 0 THEN PRINT, systime(), seqnum


	; cadence of the ROSA wavelength sequence in seconds
	ref_cadence = 2.112
		
	; grab initial reference image start time
	seq_start = ref_times[0]

	
	; Find the corresponding time difference between the ROSA extension and the corresponding in time reference image
	time_diff = (ROSA_times[seqnum] - seq_start)*86400.0
	
	; divide the number of seconds by the cadence to find the appropriate index of the reference image
	image_num        = ROUND(time_diff / ref_cadence)
	
	;image_num = image_num - 1
	
	IF image_num LE 0 THEN image_num = 0
	IF image_num GE Ref_ROSA_ext THEN image_num = Ref_ROSA_ext - 1
	
	;PRINT, image_num
	
	; Read in corresponding reference image number
	ref_frame = readfits(ref_im, exten=0, nslice=image_num, /SILENT)
	
	
	; read in ROSA image
	ROSA_im = readfits(chosen_ROSA_wvlnth, exten=0, nslice=seqnum, /SILENT)

	
		
	; properly rotate image to match IBIS and other ROSA wavelengths
	ROSA_im = ROTATE(ROSA_im, ROSA_rot_4170)
	

	
		
	; change initial ROSA plate scales to match target ROSA plate scales (0.06 "/pix)
	ROSA_to_scale_size= size(ROSA_im)
	px = ROUND(ROSA_to_scale_size[1]*initial_4170_ps[0]/ROSA_plate_scale)
	py = ROUND(ROSA_to_scale_size[2]*initial_4170_ps[1]/ROSA_plate_scale)
	ROSA_im = CONGRID(ROSA_im, px, py, CUBIC=-0.5)
	
	ROSA_im = ROT(ROSA_im, init_rot_4170)
	
	ROSA_im = ROSA_im - mean(ROSA_im)
	
	ROSA_seq[*,*] = avg(ROSA_im)
	ROSA_seq[*,0:872] = ROSA_im[0:892,*]
	
	;ROSA_im = SHIFT_FRAC(ROSA_im, initial_shifts[0,seqnum],initial_shifts[1,seqnum],missing=avg(ROSA_im))
	
	; 4170 initial shifts
	;ROSA_im = SHIFT_FRAC(ROSA_im, 5, 0, missing=avg(ROSA_im))

	; need to multiply shifts by -1 to get appropriate reference shifts
	; I'm shifting ROSA to match IBIS
	shifts = xyoff(ref_frame, ROSA_seq, 756, 756, /quiet)
	ROSA_to_GBAND_shifts[*,seqnum] = shifts
	
	;ROSA_seq[*,*,seqnum] = SHIFT_FRAC(ROSA_im, (shifts[0]), (shifts[1]),missing=0)
ENDFOR

SAVE, ROSA_to_GBAND_shifts, FILENAME = '/home/users/ovesa/Swirl_dataset/Shifts/11272018/ROSA2IBIS/11272018.rosa2ibisshifts.4170.sav'

PRINT, 'Alignment Complete'

END


