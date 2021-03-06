#we suppose all the preparatio is already done
BAM.folder<-'~/Califano/MBDseq_PeakCalls/bam-bai_files/'
noodles.Rda.folder<-'./'
noodles<-'noodles.C.7.spaghetti' 
noodles.bed.file<-paste0(noodles,'.bed')
# we suppose Rda is $noodles.Rda
noodles.Rda.file<-paste0(noodles.Rda.folder,noodles,'.Rda')
# the finale result is $noodles.normals.read.coverage
result<-paste0(noodles,'.normals.read.coverage')
resultfilename<-paste0(result,'.Rda')

library('Matrix')
library('rtracklayer')

message('loading noodles')
load('../noodles.C.Rda') #for dnaids, etc
message('done')

if (!noodles %in% ls()) load (noodles.Rda.file)

bamsinfolder<-list.files(BAM.folder,pattern='bam$')

normal.ids<-DNAids[contrast==0]

result.loaded<-FALSE
# we can the whole thing to noodles.M.Rda
if(file.exists(resultfilename))
{
	loaded<-load(resultfilename)
	if (result %in% loaded) 
		if (class(get(result))=='dgCMatrix' || 
				class(get(result))=='matrix')
			result.loaded<-TRUE
} 

if(!result.loaded)
{
	if (!(file.exists(noodles.bed.file) && (file.info(noodles.bed.file)$size>0)))
		export(get(noodles),con=noodles.bed.file,format='bed')

	message('scanning bam file names')
	normal.bam.names<-unlist(lapply(normal.ids,function(id){
		id<-strsplit(id,',')[[1]][1]	#remove all after ,	
		sample_files<-bamsinfolder[grep(id,bamsinfolder)]
		enriched_sample_files<-sample_files[grep('nrich',sample_files)]
		}))
	message('done')

 	resultmatrix<-Matrix(nrow=length(get(noodles)),ncol=0,sparse=TRUE)

	#resultmatrix<-matrix(0,ncol=length(normal.ids),nrow=length(get(noodles)),sparse = TRUE)


	for (sample.no in 1:length(normal.ids))
	{
		message(normal.ids[sample.no])
		bamfilename<-normal.bam.names[sample.no]
		countfilename<-paste0(bamfilename,'.count')
		if(!(file.exists(countfilename) && file.info(countfilename)$size>0))
		{
			bamfilefullpath<-paste0(BAM.folder,bamfilename)
			bambedfilename<-paste0(bamfilename,'.bed')
			bed.create.command<-paste0('bedtools bamtobed -i ',bamfilefullpath,' > ',bambedfilename)
			message(bed.create.command)
			shell(bed.create.command)
			intersect.command<-paste0('bedtools intersect -c -a ',noodles.bed.file,' -b ', bambedfilename, ' | cut -f7 > ',countfilename)
			message(intersect.command)
			shell(intersect.command)
		}
		data<-read.table(countfilename,nrows=length(get(noodles)),colClasses=c('numeric'),comment.char='')
		if(dim(resultmatrix)[2]>0) resultmatrix=cBind(resultmatrix,Matrix(data[[1]],ncol=1,nrow=length(get(noodles)),sparse=TRUE))
		else resultmatrix<-Matrix(data[[1]],ncol=1,nrow=length(get(noodles)),sparse=TRUE) #first time
		#unlink(c(bambedfilename,countfilename))
	}
	colnames(resultmatrix)<-normal.ids
	assign(result,resultmatrix)
	save(file=resultfilename,list=c(result,'noodles','normal.bam.names','BAM.folder'))
}
