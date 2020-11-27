function net = cnntrain(net, x, y, opts)
    hwait = waitbar(0, '��ʼѵ������ ...');
    m = size(x, 3);
    numbatches = m / opts.batchsize;
    if rem(numbatches, 1) ~= 0
        error('numbatches not integer');
    end
    net.rL = [];
    for i = 1 : opts.numepochs
        disp(['epoch ' num2str(i) '/' num2str(opts.numepochs)]);
        tic;
        kk = randperm(m);                       %��1��m��Щ�����漴���ҳ�һ����������

        for l = 1 : numbatches
            waitbar((l+(i-1)*numbatches)/ opts.numepochs * numbatches, hwait, sprintf('����ѵ��:%d/%d @epcoh: %d/%d', l,numbatches,i,opts.numepochs));

            batch_x = x(:, :, kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
            batch_y = y(:,    kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));
            
            for lay = 2 : numel(net.layers)     %  for each layer
                if strcmp(net.layers{lay}.type, 'c')
                    num_maps = net.layers{lay}.outputmaps;
                    used_maps = rand(num_maps,1) > opts.dropout;
                    net.layers{lay}.used_maps = used_maps;
                end
            end
            net = cnnff(net, batch_x);
            net = cnnbp(net, batch_y);
            net = cnnapplygrads(net, opts);
            if isempty(net.rL)
                net.rL(1) = net.L;
            end
            net.rL(end + 1) = 0.99 * net.rL(end) + 0.01 * net.L;
        end
        toc;
    end
    
    for lay = 2 : numel(net.layers)   %  for each layer
        if strcmp(net.layers{lay}.type, 'c')
            num_maps = net.layers{lay}.outputmaps;
            used_maps = ones(num_maps,1);
            net.layers{lay}.used_maps = used_maps;
        end
    end
    
    close(hwait);    
end
