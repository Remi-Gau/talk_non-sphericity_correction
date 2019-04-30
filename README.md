# Material to talk about sphericity correction in neuroimaging

Used for a journal club around the article _Accurate autocorrelation modeling
substantially improves fMRI reliability_

Slides of the talk are [here](https://docs.google.com/presentation/d/1aaYEnMzA9F7X84c0vxb0Zmf8NMxIIv9RonAQqSPJMew/edit?usp=sharing)

A lot of the slides and format has been heavily influenced by Jeanette Mumford youtube series but it uses only matlab tools and has scripts that will go (should at least) get the data for you. It will also do the preprocessing, specify the model, run the GLM for you and then extract the data and so on. Things it does not do: serves you fries, your laundry, answer emails.

Another source of inspiration was Cyril Pernet and some of his great material for beginners to understand GLMs.

Those scripts will require matlab and SPM12 to run properly. I doubt this is fully octave compatible.

## What do we have here?

### inputs
This folder contains the ROI used to extract the data that will be playing with first.

SPM data sets will also be downloaded there.

### stand alone scripts

`depart_from_sphericity`
Script used to generate a 2D gaussian with different covariance matrix to compare white and coloured noise.

Also generate white noise residuals to simuate a 'perfect GLM' and see how ideal residuals should look like.

### demos relying on the data sets from the SPM website

You can check how improving of your models will impact your betas and change your residuals.

To do this you first need to download, preprocess and run the basic GLM on either the auditory or face data set from SPM. Run the scripts `block_01_data_preprocess_FFX.m` or follow the instruction in `event_01_data_preprocess_FFX.m`

You then might need to create the ROIs that will be needed to extract the data we will play with. The script `create_ROIs` will do that for you. This should only be required if you are planning to use the ROIs from neurosynth as they need thresholding.

Extracting the data is done by the scripts `*_02_extract_data.m`. You can modify the scripts to say whether you want to use the neurosynth ROIs or the ROI of the biggest significant cluster (for the main effect) of the data set you want to play with.

Finally you can play around with different types of model by running the different sections of the misnamed `*_03_HPF_sphericity_correction.m` scripts and see how it changes the GLM results (`run_GLM.m` and `plot_results_GLM.m` will do that) and the residuals (`plot_residuals` does this).
