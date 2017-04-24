classdef VseMitsubaEmitterSpectra < VseStyle
    % Apply light spectra based on a list of spectrum values.
    
    properties
        spectra;
        pluginType = 'area';
        propertyName = 'radiance'
        emitterType = 'emitter';
    end
    
    methods
        function obj = VseMitsubaEmitterSpectra(varargin)
            obj.elementTypeFilter = 'nodes';
            obj.destination = 'Mitsuba';
            
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
        end
        
        function addSpectrum(obj, value)
            emitter = struct('type', 'spectrum', 'value', value);
            if isempty(obj.spectra)
                obj.spectra = {emitter};
            else
                obj.spectra{end+1} = emitter;
            end
        end
        
         function addManySpectra(obj, values)
            for vv = 1:numel(values)
                obj.addSpectrum(values{vv});
            end
        end
 
        % Choose a spectrum for each selected element.
        function scene = applyToSceneElements(obj, scene, elements, hints)
            
            nSpectra = numel(obj.spectra);
            if 0 == nSpectra
                return;
            end
            
            nElements = numel(elements);
            for ee = 1:nElements
                mitsubaElement = elements{ee};
                
                % restrict to emitters of a particular plugin type
                emitter = mitsubaElement.find(mitsubaElement.id, 'type', obj.emitterType);
                if isempty(emitter) || ~strcmp(emitter.pluginType, obj.pluginType)
                    continue;
                end
                
                % choose a spectrum
                spectrumIndex = 1 + mod(ee - 1, nSpectra);
                spectrum = obj.spectra{spectrumIndex};
                resolvedSpectrum = obj.resolveResource(spectrum.value, hints);
                
                % assign the spectrum
                emitter.setProperty(obj.propertyName, 'spectrum', resolvedSpectrum);
            end
        end   
    end
end
