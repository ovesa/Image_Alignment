;;; @oanavesa
;;; The code aligns fits files by cross correlation method
;;; uses the previous image in sequence as reference
;;; Reads in fits files one by one to avoid overloading memory
;;; manual selection of which frames need to be re-adjusted were determined by glancing
;;; at the shifts and shifted images following the first cross-correlation

im_file = '11102017.ROSA.CaK.fits'
date = '11102017'

; sequence information
; starting sequence frame
seqstart = 1
; total frames in sequence
total_ims = 291
seqend = total_ims - 1
; initial primary frame used
; should be the previous frame from seqstart if not starting from 0
primary_frame = seqstart - 1

print, 'Starting at frame ', seqstart
print, 'Total number of frames ', total_ims

; arrays to hold shifted images and shifts
; ROSA images are initially 1004x1002, but they have a wide grey border
; trimming that border
im_shifted = fltarr(960,960,total_ims)
im_xyoff= fltarr(2,total_ims)

print, 'Starting the cross-correlation...'
print, 'Initial reference image is frame ', primary_frame


;;; primary image = reference = use the first or second image of series
primary_image = readfits(im_file,exten=1,nslice=primary_frame, /Silent)

; crop image to get rid of some of the grey border
primary_image = primary_image[20:979,20:979]

; place primary image in arrays
im_shifted[*,*,0] = primary_image
im_xyoff[*,0] = 0 ;initial shifts will be 0

; clear up memory
primary_image = 0

; frames chosen that needed manual adjustment
frames_to_recalibrate = [37, 201]
; corresponding reference frames
references_to_frames = [35, 199]
; cross correlation box size
xyoff_boxsize = [256, 256 ]

FOR ext=seqstart,seqend DO BEGIN 

	; the reference image will always be the previous ext
	reference_ext = ext - 1
	
	PRINT, SYSTIME(), '   Position: ', ext, '   Reference: ', reference_ext
	
	; the reference image will always be the previous
	im_ref = im_shifted[*,*,reference_ext]
	
	; read in the current frame corresponding to ext
	im_next = readfits(im_file,exten=1,nslice=ext, /Silent)
	
	; crop image to get rid of some of the grey border
	im_next = im_next[20:979,20:979]

	; cross correlation
	shifts=xyoff(im_ref,im_next, 256, 256, /quiet) 
	
	; save shifts
	im_xyoff[*,ext] = shifts
	
	; shift image
	;im_shifted[*,*,ext] = SHIFT(im_next, (shifts[0]), (shifts[1]))
	im_shifted[*,*,ext] = SHIFT_FRAC(im_next, (shifts[0]), (shifts[1])) ;,missing=-151.41187)
	
	
	IF (ext EQ 141) THEN BEGIN
	
		; the reference image will always be the previous ext
		reference_ext = ext - 1
		
		PRINT, SYSTIME(), '   Position*: ', ext, '   Reference: ', reference_ext
		
		; the reference image will always be the previous
		im_ref = im_shifted[*,*,reference_ext]
		
		; read in the current frame corresponding to ext
		im_next = readfits(im_file,exten=1,nslice=ext, /Silent)
	
		; crop image to get rid of some of the grey border
		im_next = im_next[20:979,20:979]
		
		; cross correlation
		shifts=xyoff(im_ref,im_next, 256, 256, /quiet) 
		
		first_xyoff = SHIFT_FRAC(im_next, (shifts[0]), (shifts[1])) 
		
		; cross correlation
		shifts=xyoff(im_ref,first_xyoff, 256, 256, /quiet) 
		
		; save shifts
		im_xyoff[*,ext] = shifts
	
		; shift image
		;im_shifted[*,*,ext] = SHIFT(im_next, (shifts[0]), (shifts[1]))
		im_shifted[*,*,ext] = SHIFT_FRAC(first_xyoff, (shifts[0]), (shifts[1]))
	ENDIF
	
	
	IF TOTAL(frames_to_recalibrate EQ ext) EQ 1 THEN BEGIN
		; index corresponding to extension in for loop	
		index = where(frames_to_recalibrate EQ ext)	
		
		; grabbing associated reference image
		chosen_reference_image = references_to_frames[index]
		
		; grabbing associated cross correlation box size
		box_size = xyoff_boxsize[index]
		
		PRINT, 'Chosen frame: ', ext, '   Reference ', chosen_reference_image, '   Box Size ', box_size
		
		; selecting the selected frame as the reference image
		im_ref = im_shifted[*,*,chosen_reference_image]
		
		; extension of frame which needs some manual adjustments
		im_next = readfits(im_file,exten=1,nslice=ext, /Silent)
	
		; crop image to get rid of some of the grey border
		im_next = im_next[20:979,20:979]
	
		; cross correlation
		shifts=xyoff(im_ref,im_next, box_size, box_size, /quiet) 
		
		; save shifts
		im_xyoff[*,ext] = shifts

		; shift image
		im_shifted[*,*,ext] = SHIFT_FRAC(im_next, (shifts[0]), (shifts[1])) ;,missing=-151.41187)
	ENDIF
	
ENDFOR


print, 'Saving FITS File...'
writefits, date + '.ROSA.CAK.aligned.fits', im_shifted[35:920,38:912,*]
SAVE, im_xyoff, FILENAME = date + '.ROSACAK.Shifts.sav'

print, 'DONE ', SYSTIME()
END

;FOR ext=seqstart,seqend DO BEGIN & im = readfits(im_file,exten=1,nslice=ext,hdr,/Silent) & im = im[20:979,20:979] & im -= mean(im) & im_shifted[*,*,ext] = im & print, ext & ENDFOR
