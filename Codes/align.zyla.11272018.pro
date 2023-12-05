;;; @oanavesa
;;; The code aligns fits files by cross correlation method
;;; uses the previous image in sequence as reference
;;; Reads in fits files one by one to avoid overloading memory
;;; manual selection of which frames need to be re-adjusted were determined by glancing
;;; at the shifts and shifted images following the first cross-correlation

im_file = '11272018.Zyla.fits'

; sequence information
; starting sequence frame
seqstart = 1
; total frames in sequence
total_ims = 1375
seqend = total_ims - 1
; initial primary frame used
; should be the previous frame from seqstart if not starting from 0
primary_frame = seqstart - 1

print, 'Starting at frame ', seqstart
print, 'Total number of frames ', total_ims

; arrays to hold shifted images and shifts
im_shifted = fltarr(1024,1024,total_ims, /NOZERO)
im_xyoff= fltarr(2,total_ims, /NOZERO)

print, 'Starting the cross-correlation...'
print, 'Initial reference image is frame ', primary_frame


;;; primary image = reference = use the first or second image of series
primary_image = readfits(im_file,exten=1,nslice=primary_frame, /Silent)
; crop image to get rid of some of the grey border
;primary_image = primary_image[20:979,20:979]

; place primary image in arrays
im_shifted[*,*,0] = primary_image
im_xyoff[*,0] = 0 ;initial shifts will be 0

; clear up memory
primary_image = 0


FOR ext=seqstart,seqend DO BEGIN 

	; reference extension is always the previous image sequence
	reference_ext = ext - 1
	
	print, 'Current position: ', ext, '   Reference Image: ', reference_ext
	
	; the reference image will always be the previous
	im_ref = im_shifted[*,*,reference_ext]
	
	; read in the current frame corresponding to ext
	im_next = readfits(im_file,exten=1,nslice=ext, /Silent)
	
	; crop image to get rid of some of the grey border
	;im_next = im_next[20:979,20:979]

	; cross correlation
	shifts=xyoff(im_ref,im_next, 512, 512, /quiet) 
	
	; save shifts
	im_xyoff[*,ext] = shifts
	
	; shift image
	;im_shifted[*,*,ext] = SHIFT(im_next, (shifts[0]), (shifts[1]))
	im_shifted[*,*,ext] = SHIFT_FRAC(im_next, (shifts[0]), (shifts[1])) ;,missing=-151.41187)
	
	
	
ENDFOR




print, 'Saving FITS File...'
writefits, '11272018.ZYLA.aligned.fits', im_shifted[25:1005,25:1005,*]
SAVE, im_xyoff, FILENAME = '11272018.ZYLA.Shifts.sav'

print, 'DONE ', SYSTIME()

END

