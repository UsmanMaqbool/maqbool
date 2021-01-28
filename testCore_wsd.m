function [recalls, allRecalls, allrecalls_m]= testCore_wsd(db, qFeat, dbFeat, plen_opts,varargin)
    opts= struct(...
        'nTestSample', inf, ...
        'recallNs', [1:5, 10:5:100], ...
        'printN', 10 ...
        );
    opts= vl_argparse(opts, varargin);
    
    searcherRAW_= @(iQuery, nTop) rawNnSearch(qFeat(:,iQuery), dbFeat, nTop);
    if ismethod(db, 'nnSearchPostprocess')
        searcherRAW= @(iQuery, nTop) db.nnSearchPostprocess(searcherRAW_, iQuery, nTop);
    else
        searcherRAW= searcherRAW_;
    end
    [res, recalls, allrecalls_m]= recallAtN_wsd( searcherRAW, db.numQueries,  @(iQuery, iDb) db.isPosQ(iQuery, iDb), opts.recallNs, opts.printN, opts.nTestSample,db,plen_opts);
    
    allRecalls= recalls;
    allRecalls= mean( allRecalls, 1 )';
    

end