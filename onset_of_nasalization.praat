#Onset of Nasalization Detector for Prenasalized Vowels
#Julian Vargo (2024)
#Department of Spanish & Portuguese
#University of California, Berkeley
#Please enter the appropriate file paths into lines _, _, _


writeInfoLine: "Initializing Onset of Nasalization Detector"
appendInfoLine: newline$, "Vargo, Julian (2024). Onset of Nasalization Detector [Computer Software]"
appendInfoLine: "University of California, Berkeley. Department of Spanish & Portuguese"
appendInfoLine: "Script is loading. This may take a minute. Please stand by."
inputFolder$ = "C:\Users\julia\Documents\Test_SRT\praat_mass_analyzer"

#Create initial csv file, open up file list, and calculate the number of TextGrids in the input folder
writeFileLine: "C:\Users\julia\Documents\Test_SRT\MuHSiC_Data.csv", "phoneme,following_phone,vowel_duration,percentage_nasalized,nasalization_percentile,onset_confidence,vowel_start,vowel_end"
fileList = Create Strings as file list: "fileList", inputFolder$ + "\" +"*.TextGrid"
numberOfFiles = Get number of strings

#Start the outmost for loop, where each file is analyzed
for file to numberOfFiles
selectObject: fileList
currentFile$ = Get string: file
currentTextGrid = Read from file: inputFolder$ + "\"+ currentFile$
currentTextGrid$ = selected$("TextGrid")
currentSound = Read from file: inputFolder$ + "\"+ ( replace$(currentFile$,  ".TextGrid", ".wav"))
currentSound$ = selected$("Sound")
selectObject: currentTextGrid
numberOfPhonemes = Get number of intervals: 2
Convert to Unicode
select Sound 'currentSound$'
globalFormant = To Formant (burg)... 0 5 5500 0.025 50
select Sound 'currentSound$'
globalPitch = To Pitch 0 75 600

#Start the second-layer for loop, where each prenasal vowel interval is scanned for and then analyzed
for thisInterval from intervalNumber to numberOfPhonemes
select TextGrid 'currentTextGrid$'
thisPhoneme$ = Get label of interval: 2, thisInterval
if thisPhoneme$ = "AA0" or thisPhoneme$ = "AA1" or thisPhoneme$ = "AA2" or thisPhoneme$ = "AE0" or thisPhoneme$ = "AE1" or thisPhoneme$ = "AE2" or thisPhoneme$ = "AH0" or thisPhoneme$ = "AH1" or thisPhoneme$ = "AH2" or thisPhoneme$ = "AO0" or thisPhoneme$ = "AO1" or thisPhoneme$ = "AO2" or thisPhoneme$ = "AW0" or thisPhoneme$ = "AW1" or thisPhoneme$ = "AW2" or thisPhoneme$ = "AY0" or thisPhoneme$ = "AY1" or thisPhoneme$ = "AY2" or thisPhoneme$ = "EH0" or thisPhoneme$ = "EH1" or thisPhoneme$ = "EH2" or thisPhoneme$ = "ER0" or thisPhoneme$ = "ER1" or thisPhoneme$ = "ER2" or thisPhoneme$ = "EY0" or thisPhoneme$ = "EY1" or thisPhoneme$ = "EY2" or thisPhoneme$ = "IH0" or thisPhoneme$ = "IH1" or thisPhoneme$ = "IH2" or thisPhoneme$ = "IY0" or thisPhoneme$ = "IY1" or thisPhoneme$ = "IY2" or thisPhoneme$ = "OW0" or thisPhoneme$ = "OW1" or thisPhoneme$ = "OW2" or thisPhoneme$ = "OY0" or thisPhoneme$ = "OY1" or thisPhoneme$ = "OY2" or thisPhoneme$ = "UH0" or thisPhoneme$ = "UH1" or thisPhoneme$ = "UH2" or thisPhoneme$ = "UW0" or thisPhoneme$ = "UW1" or thisPhoneme$ = "UW2"
followerNumber = thisInterval + 1
followingPhoneme$ = "placeholder to create the variable"
if thisInterval < numberOfPhonemes
followingPhoneme$ = Get label of interval: 2, followerNumber
if followingPhoneme$ = "N" or followingPhoneme$ = "M" or followingPhoneme$ = "NG" or followingPhoneme$ = "NX" or followingPhoneme$ = "EN" or followingPhoneme$ = "EM" or followingPhoneme$ = "ENG"

    thisPhonemeStartTime = Get start point: 2, thisInterval
    thisPhonemeStartTime$ = fixed$(thisPhonemeStartTime, 4) #this converts floats into strings
    thisPhonemeEndTime = Get end point: 2, thisInterval
    thisPhonemeEndTime$ = fixed$(thisPhonemeEndTime, 4)
    duration = thisPhonemeEndTime - thisPhonemeStartTime
    duration$ = fixed$(duration, 4)
    
    #Mark interval times
    time_0 = thisPhonemeStartTime
    time_100 = thisPhonemeEndTime
    for i from 1 to 99
        time_(i) = thisPhonemeStartTime + duration * .01 * i
    endfor

    #Start gathering raw measurements and transform the measurements into meaningful nasal cues    
    for i from 1 to 99
        selectObject: globalFormant
        f1_(i) = Get value at time... 1 time_(i) Hertz Linear
        fbw1_(i) = Get bandwidth at time... 1 time_(i) Hertz Linear
        selectObject: globalPitch
        f0_(i) = Get value at time... time_(i) Hertz Linear
        #Transform baseline variables into approximate frequencies of p0 and p1.
        p0_approx = f1_(i) - f0_(i) #This sets the target frequency of p0 to ~1 peak below F1
        p1_approx = f1_(i) + f0_(i) #This sets the target freq. of p1 to ~1 peak above F1
        p0_filterLowerBound = p0_approx - f0_(i) / 3
        p0_filterUpperBound = p0_approx + f0_(i) / 3
        p1_filterLowerBound = p1_approx - f0_(i) / 3
        p1_filterUpperBound = p1_approx + f0_(i) / 3
        a1_filterLowerBound = f1_(i) - f0_(i) / 3
        a1_filterUpperBound = f1_(i) + f0_(i) / 3
        a0_filterLowerBound = f0_(i) - f0_(i) / 3
        a0_filterUpperBound = f0_(i) + f0_(i) / 3
        #Create a pass band filter around the approximated nasal peaks for the vowel. Then gather the amplitude of P0, P1, A1, A0, and frequency of Fp0
        selectObject: currentSound
        currentSoundChunk = Extract part... time_(i-1) time_(i+1) rectangular 1 on
        currentSoundChunk = Filter (pass Hann band)... p0_filterLowerBound p0_filterUpperBound 0
        p0_(i) = Get Maximum... time_(i-1) time_(i+1) sinc70
        currentSoundChunk$ = selected$("Sound")
        select Sound 'currentSoundChunk$'
        currentPitch = To Pitch 0 p0_filterLowerBound p0_filterUpperBound
        fp0_(i) = Get value at time... time_(i) Hertz Linear
        removeObject: currentPitch
        selectObject: currentSound
        currentSoundChunk = Extract part... time_(i-1) time_(i+1) rectangular 1 on
        currentSoundChunk = Filter (pass Hann band)... p1_filterLowerBound p1_filterUpperBound 0
        p1_(i) = Get Maximum... time_(i-1) time_(i+1) sinc70
        selectObject: currentSound
        currentSoundChunk = Extract part... time_(i-1) time_(i+1) rectangular 1 on
        currentSoundChunk = Filter (pass Hann band)... a1_filterLowerBound a1_filterUpperBound 0
        a1_(i) = Get Maximum... time_(i-1) time_(i+1) sinc70
        selectObject: currentSound
        currentSoundChunk = Extract part... time_(i-1) time_(i+1) rectangular 1 on
        currentSoundChunk = Filter (pass Hann band)... a1_filterLowerBound a1_filterUpperBound 0
        a1_(i) = Get Maximum... time_(i-1) time_(i+1) sinc70    
        selectObject: currentSound
        currentSoundChunk = Extract part... time_(i-1) time_(i+1) rectangular 1 on
        currentSoundChunk = Filter (pass Hann band)... a0_filterLowerBound a0_filterUpperBound 0
        a0_(i) = Get Maximum... time_(i-1) time_(i+1) sinc70

        selectObject: currentSound
        currentSoundChunk = Extract part... (i-1) (i+1) rectangular 1 on
        currentSpectrum = To Spectrum... yes
        selectObject: currentSpectrum
        currentSoundChunk = Filter (pass Hann band)... 0 1000 0
        std01k_(i) = Get standard deviation... 2
        removeObject: currentSpectrum
        removeObject: currentSoundChunk

        #Transform collected metrics into nasal cue measurements
        a1p0_(i) = a1_(i) - p0_(i)
        a1p1_(i) = a1_(i) - p1_(i)
        f1fp0_(i) = f1_(i) - fp0_(i)
        a1a0_(i) = a1_(i) - a0_(i)
    endfor

    #calculate derivatives of nasal cues
    for i from 2 to 98
        ddta1p0_(i) = (a1p0_(i+1) - a1p0_(i-1)) / (duration * .02)
        ddta1p1_(i) = (a1p1_(i+1) - a1p1_(i-1)) / (duration * .02)
        ddtf1fp0_(i) = (f1fp0_(i+1) - f1fp0_(i-1)) / (duration * .02)
        ddta1a0_(i) = (a1a0_(i+1) - a1a0_(i-1)) / (duration * .02)
        ddtf1bw_(i) = (f1bw_(i+1) - f1bw_(i-1)) / (duration * .02)
        ddtstd01k_(i) = (std01k_(i+1) - std01k_(i-1)) / (duration * .02)
    endfor

    #Scan all of the currently stored derivates to find the time at which the maximum rate of change ocurred
    maxddtf1bw = 0
    maxddta1p0 = 0
    maxddta1p1 = 0
    maxddtf1fp0 = 0
    maxddta1a0 = 0
    maxstd01k = 0
    for i from 2 to 98
        currentDerivative$ = "ddtf1bw_" + string$ (i)
        currentValue = eval currentDerivative$
        if currentValue > maxddtf1bw
            maxddtf1bw = currentValue
            percentagemaxddtf1bw = .01 * (i)
        endif
    endfor
    for i from 2 to 98
        currentDerivative$ = "ddta1p0_" + string$ (i)
        currentValue = eval currentDerivative$
        if currentValue > maxddta1p0
            maxddta1p0 = currentValue
            percentagemaxddta1p0 = .01 * (i)
        endif
    endfor
    for i from 2 to 98
        currentDerivative$ = "ddta1p1_" + string$ (i)
        currentValue = eval currentDerivative$
        if currentValue > maxddta1p1
            maxddta1p1 = currentValue
            percentagemaxddta1p1 = .01 * (i)
        endif
    endfor
    for i from 2 to 98
        currentDerivative$ = "ddtf1fp0_" + string$ (i)
        currentValue = eval currentDerivative$
        if currentValue > maxddtf1fp0
            maxddtf1fp0 = currentValue
            percentagemaxddtf1fp0 = .01 * (i)
        endif
    endfor
    for i from 2 to 98
        currentDerivative$ = "ddta1a0_" + string$ (i)
        currentValue = eval currentDerivative$
        if currentValue > maxddta1a0
            maxddta1a0 = currentValue
            percentagemaxddta1a0 = .01 * (i)
        endif
    endfor
    for i from 2 to 98
        currentDerivative$ = "ddtstd01k_" + string$ (i)
        currentValue = eval currentDerivative$
        if currentValue > maxstd01k
            maxstd01k = currentValue
            percentagemaxstd01k = .01 * (i)
        endif
    endfor

    onsetOfNasalization = (percentagemaxddtf1bw + percentagemaxddta1p0 + percentagemaxddta1p1 + percentagemaxddtf1fp0 + percentagemaxddta1a0 + percentagemaxstd01k) / 6
    onsetOfNasalization$ = fixed$(onsetOfNasalization, 4)
    stdOnsetOfNasalization = sqrt ((((onsetOfNasalization - percentagemaxddtf1bw) * (onsetOfNasalization - percentagemaxddtf1bw)) + ((onsetOfNasalization - percentagemaxddta1p1) * (onsetOfNasalization - percentagemaxddta1p1)) + ((onsetOfNasalization - ercentagemaxddtf1fp0) * (onsetOfNasalization - ercentagemaxddtf1fp0)) + ((onsetOfNasalization - percentagemaxddta1p0) * (onsetOfNasalization - percentagemaxddta1p0)) + ((onsetOfNasalization - percentagemaxddta1a0) * (onsetOfNasalization - percentagemaxddta1a0)) + ((onsetOfNasalization - percentagemaxstd01k) * (onsetOfNasalization - percentagemaxstd01k))) / 5)
    predictionConfidence = ((-1 / (sqrt (.3))) * stdOnsetOfNasalization) + 1 # A linearly calculated score for clustered standard deviation clustering. A score of 1 means the nasalization prediction is very confident. A score of 0 is the least confident prediction.
    predictionConfidence$ = fixed$(predictionConfidence, 4)
    percentageNasalized = 1 - onsetOfNasalization
    percentageNasalized$ = fixed$(percentageNasalized, 4)

phoneme,following_phone,vowel_duration,percentage_nasalized,nasalization_percentile,onset_confidence,vowel_start,vowel_end

    appendFileLine: "C:\Users\julia\Documents\Test_SRT\MuHSiC_Data.csv", thisPhoneme$,",",followingPhoneme$,",",duration$,percentageNasalized$,",",onsetOfNasalization$,",",predictionConfidence$,",",thisPhonemeStartTime$,",",thisPhonemeEndTime$,tab$
endif
endif
endif
endfor
removeObject: currentFormant
removeObject: currentPitch
removeObject: currentHarmonicity
removeObject: currentIntensity
removeObject: currentPointProcess
removeObject: currentSound
removeObject: currentTextGrid
endfor
removeObject: fileList
appendInfoLine: newline$, "Script completed successfully"