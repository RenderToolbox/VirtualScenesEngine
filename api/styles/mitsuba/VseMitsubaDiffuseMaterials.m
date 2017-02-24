classdef VseMitsubaDiffuseMaterials < VseStyle
    % Apply matte materials based on a list of spectra or textures.
    
    properties
        reflectances;
        textureTemplate;
    end
    
    methods
        function obj = VseMitsubaDiffuseMaterials(varargin)
            obj.elementTypeFilter = 'materials';
            obj.destination = 'Mitsuba';
            
            texture = MMitsubaElement('template', 'texture', 'bitmap');
            texture.setProperty('gamma', 'float', 1);
            texture.setProperty('maxAnisotropy', 'float', 20);
            texture.setProperty('uoffset', 'float', 0);
            texture.setProperty('voffset', 'float', 0);
            texture.setProperty('uscale', 'float', 1);
            texture.setProperty('vscale', 'float', 1);
            texture.setProperty('wrapMode', 'string', 'repeat');
            texture.setProperty('filterType', 'string', 'ewa');
            obj.textureTemplate = texture;
            
            parser = MipInputParser();
            parser.addProperties(obj);
            parser.parseMagically(obj);
        end
        
        function addSpectrum(obj, value)
            reflectance = struct('type', 'spectrum', 'value', value);
            if isempty(obj.reflectances)
                obj.reflectances = reflectance;
            else
                obj.reflectances(end+1) = reflectance;
            end
        end
        
        function addManySpectra(obj, values)
            for vv = 1:numel(values)
                obj.addSpectrum(values{vv});
            end
        end
        
        function addTexture(obj, value)
            reflectance = struct('type', 'texture', 'value', value);
            if isempty(obj.reflectances)
                obj.reflectances = reflectance;
            else
                obj.reflectances(end+1) = reflectance;
            end
        end
        
        function addManyTextures(obj, values)
            for vv = 1:numel(values)
                obj.addTexture(values{vv});
            end
        end
        
        % Declare textures for the top of the scene file.
        function scene = applyToWholeScene(obj, scene, hints)
            isTexture = strcmp({obj.reflectances.type}, 'texture');
            for tt = find(isTexture)
                texture = obj.textureTemplate.copy();
                
                reflectance = obj.reflectances(tt);
                textureId = VseMitsubaDiffuseMaterials.idForTexture(reflectance.value);
                texture.id = textureId;
                
                resolvedTexture = obj.resolveResource(reflectance.value, hints);
                texture.setProperty('filename', 'string', resolvedTexture);
                
                scene.prepend(texture);
            end
        end
        
        % Choose a reflectance for each selected element.
        function scene = applyToSceneElements(obj, scene, elements, hints)
            
            nReflectances = numel(obj.reflectances);
            if 0 == nReflectances
                return;
            end
            
            nElements = numel(elements);
            for ee = 1:nElements
                mitsubaElement = elements{ee};
                
                % choose a spectrum
                reflectanceIndex = 1 + mod(ee - 1, nReflectances);
                reflectance = obj.reflectances(reflectanceIndex);
                
                % assign the spectrum
                mitsubaElement.pluginType = 'diffuse';
                mitsubaElement.nested = {};
                switch reflectance.type
                    case 'spectrum'
                        resolvedSpectrum = obj.resolveResource(reflectance.value, hints);
                        mitsubaElement.setProperty('reflectance', 'spectrum', resolvedSpectrum);
                    case 'texture'
                        textureId = VseMitsubaDiffuseMaterials.idForTexture(reflectance.value);
                        mitsubaElement.append(MMitsubaProperty.withData('', 'ref', ...
                            'id', textureId, ...
                            'name', 'reflectance'));
                end
            end
        end
    end
    
    methods (Static)
        function id = idForTexture(fileName)
            [~, fileBase, fileExt] = fileparts(fileName);
            id = [fileBase '_' fileExt(2:end)];
        end
    end
end
