;; 09/27/2023
;; Simple alignment code for a 3D array/time series cube
;; Align time sequence to the previous image


; Read in data

cube1_file = path_to_file
cube1         = readfits(cube1_file, hdr /Silent)

; Grab dimensions of cube

cube_size = size(cube1,/DIM)

; sequence information
seqstart = 1
seqend = cube_size[2]

; Create empty 3D array to store aligned time sequence
cube_realigned = FLTARR(cube_size[0],cube_size[1],seqend,/NOZERO)

; The first image sequence is technically already aligned
cube_realigned[*,*,0] = cube1[*,*,0]

; Empy array to store shifts if needed 
cube_shifts = FLTARR(2,seqend,/NOZERO)
cube_shifts[*,0] = 0

; Cross-correlation Information
; Size of the box to do the cross-correlation function -- depends on your array size. Aim for powers of 2
box_x = 256
box_y = 256

; The main body of the code that aligns each successive image to the previously aligned image in the sequence
; Cross-correlation to align images
FOR seqnum = seqstart,seqend-1 DO BEGIN & $
    IF (seqnum MOD 50) EQ 0 THEN PRINT, systime(), seqnum & $
    reference_extension = seqnum - 1 & $
    reference_im = cube_realigned[*,*,reference_extension] & $
    im_shifts = xyoff(reference_im, cube1[*,*,seqnum], box_x,box_y, /quiet) & $
    cube_shifts[*,seqnum] = im_shifts & $
    cube_realigned[*,*,seqnum] = SHIFT_FRAC(cube1[*,*,seqnum],(im_shifts[0]), (im_shifts[1]), missing=avg(cube1[*,*,seqnum])) & $
ENDFOR

; Write out Files
output_path = path_to_store_aligned_image_sequence
name_of_aligned_file = name_of_aligned_image_sequence
name_of_shifts_file = "arrayshifts.sav"

; Write out newly aligned image sequence to a FITs file
writefits, output_path + name_of_aligned_file, cube_realigned, hdr

; save shifts in an IDL SAV format
variables = 'cube_shifts'
res = EXECUTE('cube_shifts'   + ' = cube_shifts')
saveoutput = execute('save,' + variables + ', filename=''' + name_of_shifts_file + ''' ')

END
