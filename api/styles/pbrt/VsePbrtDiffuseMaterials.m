classdef VsePbrtDiffuseMaterials < VseStyle
    % Apply matte materials based on a list of spectra or textures.
    
    properties
        pixelType = 'spectrum';
        reflectances;
        textureTemplate;
    end
    
    methods
        function obj = VsePbrtDiffuseMaterials(varargin)
            obj.elementTypeFilter = 'materials';
            obj.destination = 'PBRT';
            
            texture = MPbrtElement('Texture');
            texture.value = {'template', obj.pixelType};
            texture.type = 'imagemap';
            texture.setParameter('filename', 'string', '');
            texture.setParameter('gamma', 'float', 1);
            texture.setParameter('maxanisotropy', 'float', 20);
            texture.setParameter('udelta', 'float', 0);
            texture.setParameter('vdelta', 'float', 0);
            texture.setParameter('uscale', 'float', 1);
            texture.setParameter('vscale', 'float', 1);
            texture.setParameter('wrap', 'string', 'repeat');
            texture.setParameter('trilinear', 'bool', false);
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
        
        function texture = newTexture(obj, name)
            texture = MPbrtElement(obj.textureTemplate.identifier, ...
                'type', obj.textureTemplate.type);
            texture.value = {name, obj.pixelType};
            texture.name = name;
            texture.parameters = obj.textureTemplate.parameters;
        end
        
        % Declare textures for the top of the scene file.
        function scene = applyToWholeScene(obj, scene, hints)
            isTexture = strcmp({obj.reflectances.type}, 'texture');
            for tt = find(isTexture)
                reflectance = obj.reflectances(tt);
                textureId = VsePbrtDiffuseMaterials.idForTexture(reflectance.value);
                texture = obj.newTexture(textureId);
                
                [~, resolvedFullPath] = obj.resolveResource(reflectance.value, hints);
                recodedTexture = obj.recodeImage(resolvedFullPath, hints);
                texture.setParameter('filename', 'string', recodedTexture);
                
                scene.world.prepend(texture);
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
                pbrtElement = elements{ee};
                
                % choose a spectrum
                reflectanceIndex = 1 + mod(ee - 1, nReflectances);
                reflectance = obj.reflectances(reflectanceIndex);
                
                % assign the spectrum
                pbrtElement.type = 'matte';
                pbrtElement.parameters = [];
                switch reflectance.type
                    case 'spectrum'
                        resolvedSpectrum = obj.resolveResource(reflectance.value, hints);
                        pbrtElement.setParameter('Kd', 'spectrum', resolvedSpectrum);
                    case 'texture'
                        textureId = VseMitsubaDiffuseMaterials.idForTexture(reflectance.value);
                        pbrtElement.setParameter('Kd', 'texture', textureId);
                end
            end
        end
    end
    
    methods (Static)
        function id = idForTexture(fileName)
            [~, fileBase] = fileparts(fileName);
            id = [fileBase '_' 'texture'];
        end
    end
end
