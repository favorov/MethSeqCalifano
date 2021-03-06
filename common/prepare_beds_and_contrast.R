#prepare bed file names for Joe Califano's project
#it is folder with bed files
peakbedsfolder<-paste0(data.folder,'/PeakCalls/bedfiles/')

bedsinfolder<-list.files(peakbedsfolder)

bed.used<-logical(length(bedsinfolder))

DNAids<-Clinical$'Tumor/Tissue DNA HAND ID'[normals | tumors]
codes<-rownames(Clinical)[normals | tumors]
#we do not want to work with xeongraft & cell lines

xDNAids<-Clinical$'Tumor/Tissue DNA HAND ID'[!normals & !tumors]

contrast<-integer(0)

contrast[normals & ! tumors] <- 0
contrast[tumors & ! normals] <- 1
#contrast : 0 for normals, 1 for tumors, NA for unknown 

clinical.row.used<-!is.na(contrast)

contrast<-contrast[!is.na(contrast)]
#we do not want to work with xeongraft & cell lines

message('Assign file to names.')
message('Tumors/normals...')
bedfilenames<-lapply(DNAids,function(DNAid){ 
		DNAidKey<-strsplit(DNAid,',')[[1]][1]	#remove all after ,	
		message(DNAidKey)
		match<-grep(DNAidKey,bedsinfolder)
		if (!length(match)) 
		{
			DNAidKey<-paste0(strsplit(DNAid,'_')[[1]],collapse='') 
			#remove _ from key; sometimes, it help
			match<-grep(DNAidKey,bedsinfolder)
		}
		if (!length(match)) stop(paste0("No bed file name matched DNAid ",DNAid,".\n")); 
		if (length(match)>1) stop(paste0("More than one bed file name matches DNAid ",DNAid,".\n"));
		bedfilename<-paste0(peakbedsfolder,bedsinfolder[match[1]]);
		bed..used<-get('bed.used',pos=1)
		bed..used[match[1]]=TRUE
		assign(x='bed.used',value=bed..used,pos=1)
		bedfilename
	}
)

#a bit strange porcedure, just not to rewrite all the code based on bedfilenames/DNAids
message('Xeno/Lines...')
xbedfilenames<-lapply(xDNAids,function(DNAid){ 
		DNAidKey<-strsplit(DNAid,',')[[1]][1]	#remove all after ,
		DNAidKey<-gsub('-','_',DNAidKey)
		message(DNAidKey)
		match<-grep(DNAidKey,bedsinfolder)
		if (!length(match)) 
		{
			DNAidKey<-paste0(strsplit(DNAid,'_')[[1]],collapse='') 
			#remove _ from key; sometimes, it help
			match<-grep(DNAidKey,bedsinfolder)
		}
		if (!length(match)) stop(paste0("No bed file name matched DNAid ",DNAid,".\n")); 
		if (length(match)>1) stop(paste0("More than one bed file name matches DNAid ",DNAid,".\n"));
		bedfilename<-paste0(peakbedsfolder,bedsinfolder[match[1]]);
		bed..used<-get('bed.used',pos=1)
		bed..used[match[1]]=TRUE
		assign(x='bed.used',value=bed..used,pos=1)
		bedfilename
	}
)
message('Files assigned.\n')
bedfilenames<-unlist(bedfilenames)
xbedfilenames<-unlist(xbedfilenames)
