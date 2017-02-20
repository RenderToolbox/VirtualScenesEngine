classdef VseMitsubaEmitterSpectra < VseStyle
    % Apply light spectra based on a list of spectrum values.
    
    properties
        spectra;
        pluginType = 'area';
        propertyName = 'radiance'
    end
    
    methods
        function obj = VseMitsubaEmitterSpectra(varargin)
            obj.elementTypeFilter = 'meshes';
            obj.destination = 'Mitsuba';
            
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
                mitsubaElement = elements(ee);
                
                % restrict to emitters of a particular plugin type
                if ~strcmp(mitsubaElement.pluginType, obj.pluginType)
                    continue;
                end
                
                % choose a spectrum
                spectrumIndex = 1 + mod(ee - 1, nSpectra);
                spectrum = obj.spectra{spectrumIndex};
                resolvedSpectrum = obj.resolveResource(spectrum, hints);
                
                % assign the spectrum
                mitsubaElement.setProperty(obj.propertyName, 'spectrum', resolvedSpectrum);
            end
        end
    end
end
