movie_list = dataset.getFullMovieList();
movie = movie_list{1};
traces = dataset.getTraces(dataset.getNeuronIDList(), movie);
figure
imagesc(traces)


dataset.plotTracesSimple(2); 