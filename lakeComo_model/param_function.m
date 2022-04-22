classdef param_function
    %PARAM_FUNCTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        M;
        K;
        N;
        
        % function input/output normalization
        input_max;
        output_max;
        input_min;
        output_min;
        % function input/output standardization
        input_mean;
        output_mean;
        input_std;
        output_std;
    end
    
    methods
        function obj = param_function()
            %PARAM_FUNCTION Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function outputArg = getInputNumber(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.M;
        end
        
        function outputArg = getOutputNumber(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.K;
        end
        
        function outputArg = get_StdOutput(obj, pInput)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            stdInpu = (pInput(:)-obj.input_mean)./obj.input_std;
            stdOutp = obj.get_output( stdInpu );
            outputArg = stdOutp.*obj.output_std + obj.output_mean;
        end
        
        function outputArg = get_NormOutput(obj, pInput)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            normInpu = (pInput(:)-obj.input_min)./(obj.input_max-obj.input_min);
            normOutp = obj.get_output( normInpu );
            outputArg = normOutp.*(obj.output_max-obj.output_min) + obj.output_min;
        end
        
        %% set max min input
        
        function obj = setMaxInput(obj, pV)
            
            obj.input_max = pV(:);
        end
        
        function obj = setMaxOutput(obj, pV)
            
            obj.output_max = pV(:);
        end
        
        function obj = setMinInput(obj, pV)
            
            obj.input_min = pV(:);
        end
        
        function obj = setMinOutput(obj, pV)
            
            obj.output_min = pV(:);
        end
        
        
         %% set mean std input output
        
        function obj = setMeanInput(obj, pV)
            
            obj.input_mean = pV(:);
        end
        
        function obj = setMeanOutput(obj, pV)
            
            obj.output_mean = pV(:);
        end
        
        function obj = setStdInput(obj, pV)
            
            obj.input_std = pV(:);
        end
        
        function obj = setStdOutput(obj, pV)
            
            obj.output_std = pV(:);
        end
        
    end
end

