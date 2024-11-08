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
writeFileLine: "C:\Users\julia\Documents\Test_SRT\Nasalization_Data.csv", "phoneme,following_phone,vowel_duration,percentage_nasalized,nasalization_percentile,onset_confidence,vowel_start,vowel_end,disFromMean_maxddtf1bw,disFromMean_maxddta1p0,disFromMean_maxstd01k"
fileList = Create Strings as file list: "fileList", inputFolder$ + "\" +"*.TextGrid"
numberOfFiles = Get number of strings

#Start the outmost for loop, where each file is analyzed
for file to numberOfFiles
selectObject: fileList
currentFile$ = Get string: file
currentTextGrid = Read from file: inputFolder$ + "\"+ currentFile$
currentTextGrid$ = selected$("TextGrid")
currentSound = Read from file: inputFolder$ + "\"+ (replace$(currentFile$,  ".TextGrid", ".wav", 4))
currentSound$ = selected$("Sound")
selectObject: currentTextGrid
numberOfPhonemes = Get number of intervals: 2
Convert to Unicode
select Sound 'currentSound$'
globalFormant = To Formant (burg)... 0 5 5500 0.025 50
select Sound 'currentSound$'
globalPitch = To Pitch... 0 75 600
intervalNumber = 1
fileSoundChunkName$ = currentFile$ + "_part"

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
    thisPhonemeStartTime$ = fixed$(thisPhonemeStartTime, 4)
    thisPhonemeEndTime = Get end point: 2, thisInterval
    thisPhonemeEndTime$ = fixed$(thisPhonemeEndTime, 4)
    duration = thisPhonemeEndTime - thisPhonemeStartTime
    duration$ = fixed$(duration, 4)

    for i from 0 to 20
        time [i] = thisPhonemeStartTime + (duration * 0.05 * i)
    endfor

    #Start gathering raw measurements and transform the measurements into meaningful nasal cues    
    for i from 1 to 19
        selectObject: globalFormant
        currentTime = time [i]
        previousTime = time [i-1]
        nextTime = time [i+1]
        f1 [i] = Get value at time... 1 currentTime Hertz Linear
        currentf1 = f1 [i]
        f1bw [i] = Get bandwidth at time... 1 currentTime Hertz Linear
        currentf1bw = f1bw [1]
        selectObject: globalPitch
        f0 [i] = Get value at time... currentTime Hertz Linear
        p0_approx = f1 [i] - f0 [i]
        p1_approx = f1 [i] + f0 [i] 
        p0_filterLowerBound = p0_approx - f0 [i] / 4
        p0_filterUpperBound = p0_approx + f0 [i] / 4
        p1_filterLowerBound = p1_approx - f0 [i] / 4
        p1_filterUpperBound = p1_approx + f0 [i] / 4
        a1_filterLowerBound = f1 [i] - f0 [i] / 4
        a1_filterUpperBound = f1 [i] + f0 [i] / 4
        a0_filterLowerBound = f0 [i] - f0 [i] / 4
        a0_filterUpperBound = f0 [i] + f0 [i] / 4
        segmentDuration = duration * 0.1
        mockLowerBound = 6.45 / segmentDuration

        currentf1 = f1 [i]
        currentf1$ = fixed$(currentf1, 10)
        currentf0 = f0 [i]
        currentf0$ = fixed$(currentf0, 10)
        p0_filterLowerBound$ = fixed$(p0_filterLowerBound, 10)
        p0_filterUpperBound$ = fixed$(p0_filterUpperBound, 10)

        if p0_filterLowerBound$ <> "--undefined--"
        selectObject: currentSound
        currentSoundChunk = Extract part... previousTime nextTime rectangular 1 on
        selectObject: currentSoundChunk
        currentSoundChunk2 = Filter (pass Hann band)... p0_filterLowerBound p0_filterUpperBound 1
        currentIntensity = To Intensity... mockLowerBound 0 yes
        p0 [i] = Get maximum... previousTime nextTime sinc70
        removeObject: currentSoundChunk
        removeObject: currentSoundChunk2
        removeObject: currentIntensity

        # selectObject: currentSound
        # currentSoundChunk = Extract part... previousTime nextTime rectangular 1 on
        # currentPitch = To Pitch... 0 mockLowerBound p0_filterUpperBound
        # fp0 [i] = Get value at time... currentTime Hertz Linear
        # removeObject: currentSoundChunk
        # removeObject: currentPitch

        # selectObject: currentSound
        # currentSoundChunk = Extract part... previousTime nextTime rectangular 1 on
        # selectObject: currentSoundChunk
        # currentSoundChunk2 = Filter (pass Hann band)... p1_filterLowerBound p1_filterUpperBound 1
        # currentIntensity = To Intensity... mockLowerBound 0 yes
        # p1 [i] = Get maximum... previousTime nextTime sinc70
        # removeObject: currentSoundChunk
        # removeObject: currentIntensity
        # removeObject: currentSoundChunk2


        selectObject: currentSound
        currentSoundChunk = Extract part... previousTime nextTime rectangular 1 on
        selectObject: currentSoundChunk
        currentSoundChunk2 = Filter (pass Hann band)... a1_filterLowerBound a1_filterUpperBound 1
        currentIntensity = To Intensity... mockLowerBound 0 yes
        a1 [i] = Get maximum... previousTime nextTime sinc70
        removeObject: currentSoundChunk
        removeObject: currentIntensity
        removeObject: currentSoundChunk2

        # selectObject: currentSound
        # currentSoundChunk = Extract part... previousTime nextTime rectangular 1 on
        # selectObject: currentSoundChunk
        # currentSoundChunk2 = Filter (pass Hann band)... a0_filterLowerBound a0_filterUpperBound 1
        # currentIntensity = To Intensity... mockLowerBound 0 yes
        # a0 [i] = Get maximum... previousTime nextTime sinc70
        # removeObject: currentSoundChunk
        # removeObject: currentIntensity
        # removeObject: currentSoundChunk2

        selectObject: currentSound
        currentSoundChunk = Extract part... previousTime nextTime rectangular 1 on
        selectObject: currentSoundChunk
        currentSoundChunk2 = Filter (pass Hann band)... 0 1000 1
        currentSpectrum = To Spectrum... yes
        selectObject: currentSpectrum
        std01k [i] = Get standard deviation... 2
        removeObject: currentSpectrum
        removeObject: currentSoundChunk
        removeObject: currentSoundChunk2

        #Transform collected metrics into nasal cue measurements
        a1p0 [i] = a1 [i] - p0 [i]
        # a1p1 [i] = a1 [i] - p1 [i]
        # f1fp0 [i] = f1 [i] - fp0 [i]
        # a1a0 [i] = a1 [i] - a0 [i]
    endif
    endfor

    #calculate derivatives of nasal cues
    for i from 2 to 18
    if f1 [i] <> undefined or f0 [i] <> undefined
        ddta1p0 [i] = (a1p0 [i+1] - a1p0 [i-1]) / (duration * 0.1)
        # ddta1p1 [i] = (a1p1 [i+1] - a1p1 [i-1]) / (duration * 0.1)
        # ddtf1fp0 [i] = (f1fp0 [i+1] - f1fp0 [i-1]) / (duration * 0.1)
        # ddta1a0 [i] = (a1a0 [i+1] - a1a0 [i-1]) / (duration * 0.1)
        ddtf1bw [i] = (f1bw [i+1] - f1bw [i-1]) / (duration * 0.1)
        ddtstd01k [i] = (std01k [i+1] - std01k [i-1]) / (duration * 0.1)
    endif
    endfor

    #Scan all of the currently stored derivates to find the time at which the maximum rate of change ocurred
    maxddtf1bw = 0
    maxddta1p0 = 99999
    # maxddta1p1 = 99999
    # maxddtf1fp0 = 99999
    # maxddta1a0 = 99999
    maxstd01k = 0
    percentagemaxddtf1bw = 0
    percentagemaxddta1p0 = 0
    # percentagemaxddta1p1 = 0
    # percentagemaxddtf1fp0 = 0
    # percentagemaxddta1a0 = 0
    percentagemaxstd01k = 0
    for i from 2 to 18
    if f1 [i] <> undefined or f0 [i] <> undefined
        currentDerivative = ddtf1bw [i]
        if currentDerivative > maxddtf1bw
            maxddtf1bw = currentDerivative
            percentagemaxddtf1bw = 0.05 * i
        endif
    endif
    endfor
    for i from 2 to 18
    if f1 [i] <> undefined or f0 [i] <> undefined
        currentDerivative = ddta1p0 [i]
        if currentDerivative < maxddta1p0
            maxddta1p0 = currentDerivative
            percentagemaxddta1p0 = 0.05 * i
        endif
    endif
    endfor
    # for i from 2 to 18
    # if f1 [i] <> undefined or f0 [i] <> undefined
    #     currentDerivative = ddta1p1 [i]
    #     if currentDerivative < maxddta1p1
    #         maxddta1p1 = currentDerivative
    #         percentagemaxddta1p1 = 0.05 * i
    #     endif
    # endif
    # endfor
    # for i from 2 to 18
    # if f1 [i] <> undefined or f0 [i] <> undefined
    #     currentDerivative = ddtf1fp0 [i]
    #     if currentDerivative < maxddtf1fp0
    #         maxddtf1fp0 = currentDerivative
    #         percentagemaxddtf1fp0 = 0.05 * i
    #     endif
    # endif
    # endfor
    # for i from 2 to 18
    # if f1 [i] <> undefined or f0 [i] <> undefined
    #     currentDerivative = ddta1a0 [i]
    #     if currentDerivative < maxddta1a0
    #         maxddta1a0 = currentDerivative
    #         percentagemaxddta1a0 = 0.05 * i
    #     endif
    # endif
    # endfor
    for i from 2 to 18
    if f1 [i] <> undefined or f0 [i] <> undefined
        currentDerivative = ddtstd01k [i]
        if currentDerivative > maxstd01k
            maxstd01k = currentDerivative
            percentagemaxstd01k = 0.05 * i
        endif
    endif
    endfor

    onsetOfNasalization = (percentagemaxddtf1bw + percentagemaxddta1p0 + percentagemaxstd01k) / 3
    onsetOfNasalization$ = fixed$(onsetOfNasalization, 4)
    stdOnsetOfNasalization = sqrt((((onsetOfNasalization - percentagemaxddtf1bw) * (onsetOfNasalization - percentagemaxddtf1bw)) + ((onsetOfNasalization - percentagemaxddta1p0) * (onsetOfNasalization - percentagemaxddta1p0)) + ((onsetOfNasalization - percentagemaxstd01k) * (onsetOfNasalization - percentagemaxstd01k))) / 2)
    disFromMean_maxddtf1bw = percentagemaxddtf1bw - onsetOfNasalization
    disFromMean_maxddta1p0 = percentagemaxddta1p0 - onsetOfNasalization
    disFromMean_maxstd01k = percentagemaxstd01k - onsetOfNasalization
    disFromMean_maxddtf1bw$ = fixed$(disFromMean_maxddtf1bw, 4)
    disFromMean_maxddta1p0$ = fixed$(disFromMean_maxddta1p0, 4)
    disFromMean_maxstd01k$ = fixed$(disFromMean_maxstd01k, 4)
    predictionConfidence = 1 - (stdOnsetOfNasalization / sqrt(0.375))
    predictionConfidence$ = fixed$(predictionConfidence, 4)
    percentageNasalized = 1 - onsetOfNasalization
    percentageNasalized$ = fixed$(percentageNasalized, 4)
    fillervariable$ = "endOfForm"
    appendFileLine: "C:\Users\julia\Documents\Test_SRT\Nasalization_Data.csv", thisPhoneme$,",",followingPhoneme$,",",duration$,",",percentageNasalized$,",",onsetOfNasalization$,",",predictionConfidence$,",",thisPhonemeStartTime$,",",thisPhonemeEndTime$,",",disFromMean_maxddtf1bw$,",",disFromMean_maxddta1p0$,",",disFromMean_maxstd01k$,",",fillervariable$,tab$
endif
endif
endif
endfor
removeObject: globalFormant
removeObject: globalPitch
removeObject: currentSound
removeObject: currentTextGrid
endfor
removeObject: fileList
appendInfoLine: newline$, "Script completed successfully"
