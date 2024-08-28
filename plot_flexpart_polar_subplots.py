"""
Usage example:

  plot_flexpart.py grid.nc NO2 RUN_NAME

where the first argument is the name of the NetCDF file to read, the second
argument is the name of the variable to plot, and the third argument is the
run name used for the output file name.

For each output height in the file, a footprint plot will be created, which
sums all the values in the file.

Plot will be created in the current working directory ...
"""

# standard library imports:
import os
import sys
# third party imports ... use Agg backend for matplotlib:
import matplotlib
matplotlib.use('Agg')
# the rest of the third party bits:
import matplotlib.pyplot as plt
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import iris
import numpy as np
import math

# check iris major version:
IRIS_VERSION = int(iris.__version__.split('.')[0])

# when using iris version < 2 (or thereabouts), this helps avoid some
# warnings:
if IRIS_VERSION < 2:
    iris.FUTURE.netcdf_promote = True
    iris.FUTURE.netcdf_no_unlimited = True

def get_args(args_in):
    """
    check input arguments and return values if all looks o.k. ...
    """
    # check length of arguments:
    if len(args_in) != 3:
        # get name of the executable:
        self_name = os.path.basename(args_in[0])
        # print error and exit:
        sys.stderr.write('usage: {0} NC_FILE VAR_NAME RUN_NAME\n'.format(self_name))
        sys.exit()
    # get values:
    nc_file = args_in[1]
    var_name = args_in[2]
    # run_name = args_in[3]
    # return values:
    return nc_file, var_name

def main():
    """
    main function for creating plots
    """

    # check / get args:
    nc_file, var_name = get_args(sys.argv)
    

    fp_cube = iris.load_cube(nc_file, var_name)

    lat_coord = fp_cube.coord('grid_latitude')
    lon_coord = fp_cube.coord('grid_longitude')
    lat_vals = lat_coord.points
    lon_vals = lon_coord.points

    lat_min, lat_max = int(np.ceil(lat_vals.min())), int(np.floor(lat_vals.max()))
    lon_min, lon_max = int(np.ceil(lon_vals.min())), int(np.floor(lon_vals.max()))

    height_coord = fp_cube.coord('height')
    height_vals = height_coord.points

    col_bounds = [0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 5, 10, 25, 50, 100]
    col_map = [plt.cm.jet((i / len(col_bounds))) for i in range(len(col_bounds))]

    fp_time = fp_cube.coord('time')
    fp_cube_dt_start = fp_time.units.num2date(fp_time.points)[0]
    fp_cube_dt_end = fp_time.units.num2date(fp_time.points)[-1]
    title_time_start = fp_cube_dt_start.strftime('%Y-%m-%d %H:%M')
    title_time_end = fp_cube_dt_end.strftime('%Y-%m-%d %H:%M')

    plt_dpi = 300
    map_prj = ccrs.NorthPolarStereo()

    # Calculate the number of rows and columns for subplots
    n_heights = len(height_vals)
    n_cols = math.ceil(math.sqrt(n_heights))
    n_rows = math.ceil(n_heights / n_cols)

    # Adjust figure size based on the number of subplots
    plt_w, plt_h = 1150 * n_cols / 2, 1050 * n_rows / 2

    # Create a grid of subplots
    fig, axs = plt.subplots(n_rows, n_cols, figsize=(plt_w / plt_dpi, plt_h / plt_dpi),
                            subplot_kw={'projection': map_prj}, dpi=plt_dpi)
    
    # Flatten the array of axes for easier indexing
    axs = axs.flatten() if n_heights > 1 else [axs]  

    for idx, h in enumerate(height_vals):
        h_index = idx
        h_val = h
        h_prev = 0 if h_index == 0 else height_vals[h_index - 1]
        h_prev_int, h_int = int(round(h_prev)), int(round(h_val))

        h_cube = fp_cube[0, 0, :, h_index, :, :]
        sum_cube = h_cube.collapsed('time', iris.analysis.SUM)
        sum_cube.data[sum_cube.data == 0] = np.nan
        sum_max = np.nanmax(sum_cube.data)
        sum_cube.data[:] = (sum_cube.data / sum_max) * 100

        ax = axs[idx]
        ax.set_extent([-180, 180, 40, 90], crs=ccrs.PlateCarree())

        gl = ax.gridlines(draw_labels=False, dms=True, x_inline=False, y_inline=False)
        gl.right_labels = False
        gl.top_labels = False
        gl.xformatter = LongitudeFormatter(degree_symbol='')
        gl.yformatter = LatitudeFormatter(degree_symbol='')

        land_feature = cfeature.NaturalEarthFeature('physical', 'land', '50m',
                                                    edgecolor='face', facecolor='lightgray')
        ocean_feature = cfeature.NaturalEarthFeature('physical', 'ocean', '50m',
                                                     edgecolor='face', facecolor='lightblue')
        ax.add_feature(ocean_feature, zorder=1, alpha=0.4)
        ax.add_feature(land_feature, zorder=2)
        ax.add_feature(cfeature.COASTLINE, edgecolor='black', zorder=4, linewidth=0.5)

        contour_plot = ax.contourf(lon_vals, lat_vals,
                                   sum_cube.data, col_bounds, colors=col_map,
                                   vmin=0, vmax=100, zorder=3,
                                   extend='min', transform=ccrs.PlateCarree())

        plt_title = '{:,}m - {:,}m'.format(h_prev_int, h_int)
        ax.set_title(plt_title, fontsize=8)

    # Remove any unused subplots
    for idx in range(n_heights, len(axs)):
        fig.delaxes(axs[idx])

    # Add a colorbar that uses the full height of the plot
    cbar_ax = fig.add_axes([0.99, 0.15, 0.02, 0.7])
    fig.colorbar(contour_plot, cax=cbar_ax)

    # Set an overall title for the figure
    fig.suptitle(f'{title_time_start} - {title_time_end}', fontsize=16)

    # Adjust the layout and save the figure
    plt.tight_layout()
    plt.savefig(f'heights_subplots_{var_name}.png', dpi=plt_dpi, format='png', bbox_inches='tight')
    plt.close()

if __name__ == '__main__':
    main()
