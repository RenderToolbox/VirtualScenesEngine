classdef VsePbrtEmitterSpectra < VseStyle
    % Apply light spectra based on a list of spectrum values.
    
    properties
        spectra;
        identifier = 'AreaLightSource';
        propertyName = 'L'
    end
    
    methods
        function obj = VsePbrtEmitterSpectra(varargin)
            obj.elementTypeFilter = 'nodes';
            obj.destination = 'PBRT';
            
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
        end
        
        function addSpectrum(obj, value)
            if isempty(obj.spectra)
                obj.spectra = {value};
            else
                obj.spectra{end+1} = value;
            end
        end
        
        
        % Choose a reflectance for each selected element.
        function scene = applyToSceneElements(obj, scene, elements, hints)
            
            nSpectra = numel(obj.spectra);
            
            nElements = numel(elements);
            for ee = 1:nElements
                pbrtElement = elements{ee};
                
                % restrict to a particular pbrt identifier
                emitter = pbrtElement.find(obj.identifier);
                if isempty(emitter)
                    continue;
                end
                
                % choose a spectrum
                spectrumIndex = 1 + mod(ee - 1, nSpectra);
                spectrum = obj.spectra{spectrumIndex};
                resolvedSpectrum = obj.resolveResource(spectrum, hints);
                
                % assign the spectrum
                emitter.setParameter(obj.propertyName, 'spectrum', resolvedSpectrum);
            end
        end
    end
end
