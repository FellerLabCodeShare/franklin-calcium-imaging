# franklin-calcium-imaging
A set of functions for simple analysis of calcium imaging movies with an object-oriented approach 

start with the 'processMovies' function and call it on a spreadsheet that describes your movies. Make sure you are in the root directory that contains all your movies when the function is called. 

For an example of what column headers the spreadsheet needs to contain and what it should look like, check out 'example data guide spreadsheet.xlsx'. Notice that you don't have these movies, so unfortunately you cannot directly test drive the code using this spreadsheet. I might make an example directory and example spreasheet at some later time so people can easily test drive the code. 

processMovies is going to save 'datasets' in the directories where the movies are that contain your rois and fluorescence traces for the the rois. 'exploreCaImagingData' is a simple example of how you can visualize the data in a dataset. 

The object-oriented-approach refers to the 'FOV' and 'neuron' classes. FOV is a field of view object that contains some information about the experiment along with a set of neurons that are visible within the field of view. A neuron object ccontains an ID number, a list of movies that were taken of the neuron, a region of interest, and a collection of fluorescence traces corresponding to each of the movies, along with a few other properties and data. 

