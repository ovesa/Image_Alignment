; Directories where the shifts (SAV files) and FITS files are located
shifts_dir = '/home/users/ovesa/Swirl_dataset/Shifts/11272018/ROSA2IBIS/'
data_dir = '/boomerang-data/ovesa/swirls_data/11272018/'

; Read in SAV file containing desired shifts
shift_file_name = shifts_dir + '11272018.rosa2ibisshifts.gband.sav'


RESTORE, shift_file_name, /verbose

data_im = data_dir + '11272018.ROSA.GBAND.aligned.fits'
;gband_ref = data_dir + '11272018.GBAND.aligned.final.fits'

; grab the maximum number of images in the FITS file
fits_open, data_im ,fcb
max_exten = fcb.axis[2]
fits_close, fcb

seqstart = 0
seqend = max_exten - 1


; plate scales
; target plate_scales
IBIS_plate_scale = 0.097 ; arcsec/pix
ROSA_plate_scale = 0.06 ; arcsec/pix  0.17?
ZYLA_plate_scale = 0.083 ; arcsec/pix  0.17?

; initial plate scales - derived from dot grids
initial_gband_ps = [0.0605,0.0578]
initial_cak_ps = [0.059,0.059]
initial_4170_ps = [0.0601,0.0576]
initial_3500_ps = [ 0.06129, 0.05994]

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
init_rot_3500  = 0.892
init_rot_zyla  = 1.2 ; rotation to match ZYLA to Ha


; Read in a quick image and rotate it to initialize array
; and proper shape

;tmp_im = readfits(gband_ref, exten=0,nslice=0)
;tmp_size = size(tmp_im, /DIM)

tmp_im = readfits(data_im, exten=0,nslice=0)
tmp_im = ROTATE(tmp_im, ROSA_rot_gband)
tmp_size= size(tmp_im)
px = ROUND(tmp_size[1]*initial_gband_ps[0]/ROSA_plate_scale)
py = ROUND(tmp_size[2]*initial_gband_ps[1]/ROSA_plate_scale)
tmp_im = CONGRID(tmp_im, px, py, CUBIC=-0.5)
tmp_size = size(tmp_im, /DIM)


; set variable to 0 to clear memory
tmp_im = 0

ROSA_seq = FLTARR(tmp_size[0], tmp_size[1], max_exten, /NoZero)


PRINT, 'Applying shifts to ROSA images'
PRINT, 'Chosen ROSA File ', data_im
PRINT, 'There are ', max_exten, ' ROSA images'

FOR seqnum = seqstart, seqend DO BEGIN
	IF (seqnum MOD 20) EQ 0 THEN PRINT, systime(), seqnum

	; Read in ROSA image
	ROSA_im = readfits(data_im, exten=0, nslice= seqnum, /SILENT)

	ROSA_im = ROT(ROTATE(ROSA_im, ROSA_rot_gband), init_rot_gband, CUBIC=-0.5)
		
	; change initial ROSA plate scales to match target ROSA plate scales (0.06 "/pix)
	ROSA_to_scale_size= size(ROSA_im)
	px = ROUND(ROSA_to_scale_size[1]*initial_gband_ps[0]/ROSA_plate_scale)
	py = ROUND(ROSA_to_scale_size[2]*initial_gband_ps[1]/ROSA_plate_scale)
	ROSA_im = CONGRID(ROSA_im, px, py, CUBIC=-0.5)
	
	;ROSA_im = ROSA_im[0:892,*]
	; create temporary matrix to house image
	;tmp_seq = FLTARR(tmp_size[0], tmp_size[1], /NoZero)
	;tmp_seq[*,*] = avg(ROSA_im)
	;tmp_seq[*,*] = ROSA_im[0:892,0:877]
	
	
	ROSA_seq[*,*,seqnum] = SHIFT_FRAC(ROSA_im, (ROSA_TO_IBIS_SHIFTS[0, seqnum]), (ROSA_TO_IBIS_SHIFTS[1, seqnum]), missing=avg(ROSA_im))
	

	; Read in corresponding x/y shifts
	;ROSA_seq[*,0:872,seqnum] = SHIFT_FRAC(ROSA_im, (ROSA_TO_GBAND_SHIFTS[0, seqnum]), (ROSA_TO_GBAND_SHIFTS[1, seqnum]), missing=avg(ROSA_im))
	;ROSA_seq[*,*,seqnum] = SHIFT_FRAC(ROSA_seq[*,*,seqnum], (ROSA_TO_GBAND_SHIFTS2[0, seqnum]), (ROSA_TO_GBAND_SHIFTS2[1, seqnum]), missing=avg(ROSA_seq[*,*,seqnum]))
	;ROSA_seq[*,*,seqnum] = SHIFT_FRAC(ROSA_seq[*,*,seqnum],shifts_4170[0],shifts_4170[1], missing=avg(ROSA_seq[*,*,seqnum]))
	
	

ENDFOR




PRINT, 'Creating FITS File'

mkhdr, hdr, ROSA_seq

sxaddpar, hdr, 'DATE-OBS', '2018-11-27T16:58:00.336', 'Start time of observations', Before='DATE'

; Instrument to acquire data
sxaddpar, hdr, 'INSTRUME', 'ROSA', 'Instrument used to acquire data',Before='DATE'

; Telescope used to acquire data
sxaddpar, hdr, 'TELESCOP', 'Dunn Solar Telescope (DST)', 'Telescope used to acquire data',Before='DATE'

; wavelength
sxaddpar, hdr, 'WAVELNTH', 'G-Band', 'Wavelength',Before='DATE'

; name of coordinate projection
sxaddpar, hdr, 'WCSNAME', 'Helioprojective-cartesian', 'Name of coordinate projection',Before='DATE'


sxaddpar, hdr, 'EXPTIME', '10', 'Exposure Time [ms]',Before='DATE'

; axis type
;  Solar-X
sxaddpar, hdr, 'CTYPE1', 'HPLN-TAN', 'Solar X (cartesian west) axis',Before='DATE'
; Solar-Y
sxaddpar, hdr, 'CTYPE2', 'HPLT-TAN', 'Solar Y (cartesian north) axis',Before='DATE'

; axis units
sxaddpar, hdr, 'CUNIT1', 'arcsec', 'Arcseconds from center of Sun',Before='DATE'
sxaddpar, hdr, 'CUNIT2', 'arcsec', 'Arcseconds from center of Sun',Before='DATE'


; axis plate scale [arcsec/pixel]
sxaddpar, hdr, 'CDELT1', '0.06', 'Increments along X dimension',Before='DATE'
sxaddpar, hdr, 'CDELT2', '0.06', 'Increments along Y dimension',Before='DATE'

; cadencedata_dir = '/boomerang-data/ovesa/swirls_data/11272018/'
sxaddpar, hdr, 'CADENCE', '2.112', 'cadence [s]',Before='DATE'

;crx = float(tmp_size[0])/float(2)
;cry = float(tmp_size[1])/float(2)
; reference pixels - center of array
;sxaddpar, hdr, 'CRPIX1', crx, 'Reference pixel along X dimension',Before='DATE'
;sxaddpar, hdr, 'CRPIX2', cry, 'Reference pixel along Y dimension',Before='DATE'

; reference values - coordinate values of the reference pixels
; Solar - X
sxaddpar, hdr, 'CRVAL1', '0.1753390171',  'Reference position along X dimension',Before='DATE'
; Solar - Y
sxaddpar, hdr, 'CRVAL2', '0.03697029455',  'Reference position along Y dimension',Before='DATE'



writefits, data_dir + '11272018.GBAND.aligned.final.fits', ROSA_seq, hdr

PRINT, 'FITS file created'
PRINT, 'FITS file saved in ', data_dir


END
