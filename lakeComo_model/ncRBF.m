classdef ncRBF < param_function
    %NCRBF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        param;
        
        lin_param;
    end
    
    methods
        function obj = ncRBF(M, K, N)
            %NCRBF Construct an instance of this class
            %   Detailed explanation goes here
            obj.M = M;
            obj.K = K;
            obj.N = N;
        end
        
        function obj = clearParameters(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.param = [];
            obj.lin_param = [];
        end
        
        function obj = setParameters(obj, pTheta)
            
            obj.lin_param = pTheta(1:obj.K);
            pTheta(1:obj.K) = [];
            
            obj.param = repmat(struct( 'c', [], 'b', [], 'w', [] ), obj.N, 1);
            for i = 1:obj.N
                pcb = pTheta(1:2*obj.M);
                pTheta(1:2*obj.M) = [];
                
                pcb = reshape( pcb, 2, [] );
                obj.param(i).c = pcb(1,:);
                obj.param(i).b = pcb(2,:);
                
                obj.param(i).w = pTheta(1:obj.K);
                pTheta(1:obj.K) = [];
                
            end
            
        end

        function outputArg = getNumParams(obj)
            outputArg = obj.N*(2*obj.M+obj.K) + obj.K; 
        end
        
        function y = get_output(obj, input)
            
            % RBF
            phi = zeros(1,obj.N);
            for j = 1:obj.N
                bf = 0;
                for i = 1:obj.M
                    num = (input(i) - obj.param(j).c(i))*(input(i) - obj.param(j).c(i));
                    den = obj.param(j).b(i)*obj.param(j).b(i);
                    if den < 10^(-6)
                        den = 10^(-6);
                    end
                    bf = bf + num / den ;
                end
                phi(j) =  exp(-bf) ;
            end
            
            % output
            y = zeros(1,obj.K);
            for k = 1:obj.K
                o = obj.lin_param(k);
                for i = 1:obj.N
                    o = o + obj.param(i).w(k)*phi(i) ;
                end
                
                y(k) = o;
            end
            
            y(y>1) = 1;
            y(y<0) = 0;
            
        end
    end
end

