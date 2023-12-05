# Main code to read the Zyla camera binary files was taken from 
# Gordon's SSOC-soft package.

import glob
import os
import sys

import matplotlib.pyplot as plt
import numpy as np
from astropy.io import fits
from tqdm import tqdm


def open_zyla_binary_file(data_files):
    # mode information: r = readable; b = binary file
    with open(data_files, mode="rb") as image_file:
        image_data = np.fromfile(image_file, dtype=np.uint16)
    return image_data


def plot_zyla_image_with_overscan(imagedata):
    #  for target files 1026x1040
    im = np.reshape(imagedata, (1026, 1040))

    fig = plt.figure()
    plt.title("With Overscan")
    plt.pcolormesh(im, cmap="gray")
    plt.colorbar()
    plt.show()
    return fig


def detect_overscan_regions(imagedata):
    # np.equal returns x1==x2 element-wise
    # .view(np.int8) constructs a new view of the data using a different data type
    # in this case, np.equal() produces True or False. .view(np.int8) transforms that to binary 0s and 1s.
    iszero = np.concatenate(([0], np.equal(imagedata, 0).view(np.int8), [0]))
    absdiff = np.abs(np.diff(iszero))
    # Runs start and end where absdiff is 1.
    ranges = np.where(absdiff == 1)[0]
    return ranges


def detect_image_dimensions(imagedata):
    overscan = detect_overscan_regions(imagedata)
    # data dimensions need to be a multiple of the image size
    data_dimensions = (np.uint16(imagedata.size / overscan[1]), overscan[1])

    dx1 = overscan[1] - overscan[0]
    dx2 = overscan[2] - overscan[1]
    DeltaX = np.abs(np.diff(overscan))
    endRow = (np.where(np.logical_and(DeltaX != dx1, DeltaX != dx2))[0])[0] / 2 + 1
    image_dimensions = (np.uint16(endRow), overscan[0])

    return data_dimensions, image_dimensions


def read_binary_file(imagedata, datashape, imageshape):
    image = imagedata.reshape((datashape))
    s = tuple()
    for t in imageshape:
        s = s + np.index_exp[0:t]
    image = image[s]
    return np.float32(image)


# get current working directory
input_path = os.path.abspath(os.getcwd())
print("Your current working directory is", input_path)
print("\n")

data_directory = "/media/oana/Data/swirls/ROSA_11272018/Zyla_Target_Files/"

fname = sorted(glob.glob(data_directory + "*dat"))
path, filename = os.path.split(fname[0])

if not fname:
    print("Files do not exist: " + path, file=sys.stderr)
# for file in fname:
#    print("Files exist.")


total_images = len(fname)

print("\n")
print("There exists {} files".format(total_images))
print("\n")

final_im_arr = []
for nom in tqdm(range(total_images)):
    image_file = open_zyla_binary_file(fname[nom])
    data_dims, im_dims = detect_image_dimensions(image_file)
    final_image = read_binary_file(image_file, data_dims, im_dims)
    final_im_arr.append(final_image)

final_im_arr = np.array(final_im_arr)
print("Shape ", final_im_arr.shape)

# average image
im_ave = np.mean(final_im_arr, axis=(0))


def create_fits_file(output_filename, image):
    hdu = fits.PrimaryHDU(image)
    hdu.writeto(output_filename)
    print("Saving FITS file to ", os.path.abspath(output_filename))
    return hdu


hdu = create_fits_file("11272018.Zyla.190800.Target.Images.fits", im_ave)

