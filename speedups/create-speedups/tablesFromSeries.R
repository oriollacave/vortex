#SCRIPT TO COMPARE R2 vs AVGcoefs for EDF
library(reshape)
library(lubridate)
library(reshape)
library(ggplot2)
require(lattice)

args = commandArgs(trailingOnly=TRUE)

site=args[1]

dirs=seq(from=7.5,to=352.5,by=15)
metmasts=read.csv(paste("../../series/",site,"/metmasts.txt",sep=""),colClasses=c("character",rep("character",4)),header=F,sep=" ")
N=nrow(metmasts)
#sample for df definition

tmp=read.csv(paste("../../series/",site,"/series/serie.",metmasts[1,1],".",metmasts[1,2],".",metmasts[1,3],".",metmasts[1,4],".txt",sep=""),sep=" ",header=F)
numberofrows=nrow(tmp)

print(paste(numberofrows))
#create dataframe with series Dir,M1,M2,...,Mn
dfseries=data.frame(matrix(ncol=N+1,nrow=numberofrows))
colnames(dfseries)=c(metmasts[,1],"D")
dfseriesD=data.frame(matrix(ncol=N,nrow=numberofrows))
colnames(dfseriesD)=c(metmasts[,1])

for (n in seq(1,N)){
	print(paste("Loading data..."))
	filein=paste("../../series/",site,"/series/serie.",metmasts[n,1],".",metmasts[n,2],".",metmasts[n,3],".",metmasts[n,4],".txt",sep="")
	print(filein)
	data=read.csv(filein,sep=" ",header=F)
	if ( n == 1){
		dfseries[,"D"]=data[,4]
	}
	dfseries[,n]=data[,3]
	dfseriesD[,n]=data[,4]

}

#NOW construct dataframes
dfmeans=data.frame(matrix(ncol=N,nrow=25))
colnames(dfmeans)=as.vector(metmasts[,1])
dfcorrs=data.frame(matrix(ncol=N,nrow=25))
colnames(dfcorrs)=as.vector(metmasts[,1])
dfslopes=data.frame(matrix(ncol=N,nrow=25))
colnames(dfslopes)=as.vector(metmasts[,1])
dfortos=data.frame(matrix(ncol=N,nrow=25))
colnames(dfortos)=as.vector(metmasts[,1])

numberrows=((N)*(N-1))/2
print(paste("Number of rows:",numberrows))
tblmeans=matrix(ncol=26,nrow=numberrows)
tblcorrs=matrix(ncol=26,nrow=numberrows)
tblslopes=matrix(ncol=26,nrow=numberrows)
tblortos=matrix(ncol=26,nrow=numberrows)
frequencies=vector('numeric')

#compute metrics
kk=1
i=1
nums=seq(1,N-1)
for (numinitiation in c(nums)){
        i=i+1
        numstarget=seq(i,N)
        for (numtarget in c(numstarget)){
		if ( i== 2 ){
		timesteps=nrow(dfseries)
		frequencies[25]=1
		frequencies[1]=100*nrow(dfseries[dfseriesD[,numtarget] > dirs[24] | dfseriesD[,numtarget] < dirs[1],])/timesteps
		for (sec in seq(1,23)){
			frequencies[sec+1]=100*nrow(dfseries[dfseriesD[,numtarget] > dirs[sec] & dfseriesD[,numtarget] < dirs[sec+1],])/timesteps
		}
		}
		print(paste("Met mast ",metmasts[numinitiation,1],"vs",metmasts[numtarget,1]))
		#AVERAGE
		#name
                tblmeans[kk,1]=paste(metmasts[numinitiation,1],metmasts[numtarget,1],sep="/")
		#all period
		tblmeans[kk,26]=as.numeric(mean(dfseries[,numtarget]))/as.numeric(mean(dfseries[,numinitiation]))
		#each sector ratios
		tblmeans[kk,2]=as.numeric(mean(dfseries[dfseriesD[,numtarget] > dirs[24] | dfseriesD[,numtarget] < dirs[1],numtarget]))/as.numeric(mean(dfseries[dfseriesD[,numtarget] > dirs[24] | dfseriesD[,numtarget] < dirs[1],numinitiation]))
		for (sec in seq(1,23)){
	                tblmeans[kk,sec+2]=as.numeric(mean(dfseries[dfseriesD[,numtarget] > dirs[sec] & dfseriesD[,numtarget] < dirs[sec+1],numtarget]))/as.numeric(mean(dfseries[dfseriesD[,numtarget] > dirs[sec] & dfseriesD[,numtarget] < dirs[sec+1],numinitiation]))
		}
		#CORRELATION
		#name
                tblcorrs[kk,1]=paste(metmasts[numinitiation,1],metmasts[numtarget,1],sep="/")
		#all period
		tblcorrs[kk,26]=as.numeric(cor(dfseries[,numtarget],dfseries[,numinitiation]))
		#each sector
		tblcorrs[kk,2]=as.numeric(cor(dfseries[dfseriesD[,numtarget] > dirs[24] | dfseriesD[,numtarget] < dirs[1],numtarget],dfseries[dfseriesD[,numtarget] > dirs[24] | dfseriesD[,numtarget] < dirs[1],numinitiation]))
		for (sec in seq(1,23)){
	                tblcorrs[kk,sec+2]=as.numeric(cor(dfseries[dfseriesD[,numtarget] > dirs[sec] & dfseriesD[,numtarget] < dirs[sec+1],numtarget],dfseries[dfseriesD[,numtarget] > dirs[sec] & dfseriesD[,numtarget] < dirs[sec+1],numinitiation]))
		}
		#Slope
		#name
                tblslopes[kk,1]=paste(metmasts[numinitiation,1],metmasts[numtarget,1],sep="/")
		#all period
		fit <- lm(dfseries[,numtarget] ~ dfseries[,numinitiation]+0)
		tblslopes[kk,26]=as.numeric(fit$coefficients)
		#each sector
		fit <- lm(dfseries[dfseriesD[,numinitiation] > dirs[24] | dfseriesD[,numinitiation] < dirs[1],numtarget]~dfseries[dfseriesD[,numinitiation] > dirs[24] | dfseriesD[,numinitiation] < dirs[1],numinitiation]+0)		
		tblslopes[kk,2]=as.numeric(fit$coefficients)
		for (sec in seq(1,23)){
			fit <- lm(dfseries[dfseriesD[,numinitiation] > dirs[sec] & dfseriesD[,numinitiation] < dirs[sec+1],numtarget]~dfseries[dfseriesD[,numinitiation] > dirs[sec] & dfseriesD[,numinitiation] < dirs[sec+1],numinitiation]+0)
	                tblslopes[kk,sec+2]=as.numeric(fit$coefficients)
		}
                #Orthogonal regression
                #name
                tblortos[kk,1]=paste(metmasts[numtarget,1],metmasts[numinitiation,1],sep="/")
                #all period
                fit <- prcomp(~dfseries[,numtarget] + dfseries[,numinitiation])
                tblortos[kk,26]=as.numeric(fit$rotation[2,1]/fit$rotation[1,1])
                #each sector
                fit <- prcomp(~dfseries[dfseriesD[,numtarget] > dirs[24] | dfseriesD[,numtarget] < dirs[1],numtarget]+dfseries[dfseriesD[,numtarget] > dirs[24] | dfseriesD[,numtarget] < dirs[1],numinitiation])
                tblortos[kk,2]=as.numeric(fit$rotation[2,1]/fit$rotation[1,1])
                for (sec in seq(1,23)){
                	fit <- prcomp(~dfseries[dfseriesD[,numtarget] > dirs[sec] & dfseriesD[,numtarget] < dirs[sec+1],numtarget] + dfseries[dfseriesD[,numtarget] > dirs[sec] & dfseriesD[,numtarget] < dirs[sec+1],numinitiation])
	                tblortos[kk,sec+2]=as.numeric(fit$rotation[2,1]/fit$rotation[1,1])
                }
                kk=kk+1
        }
}
#TO NUMERIC
tblmeansnum=mapply(tblmeans[,2:26],FUN=as.numeric)
tblmeansnum<-matrix(data=tblmeansnum,ncol=25)
tblcorrsnum=mapply(tblcorrs[,2:26],FUN=as.numeric)
tblcorrsnum<-matrix(data=tblcorrsnum,ncol=25)
tblslopesnum=mapply(tblslopes[,2:26],FUN=as.numeric)
tblslopesnum<-matrix(data=tblslopesnum,ncol=25)
tblortosnum=mapply(tblortos[,2:26],FUN=as.numeric)
tblortosnum<-matrix(data=tblortosnum,ncol=25)
#GRAPHIC RASTER
levelplot(tblcorrsnum)
levelplot(tblslopesnum)
levelplot(tblmeansnum)
levelplot(tblortosnum)
png("means.png")
levelplot(tblmeansnum,at=c(seq(0,2,0.1)))
dev.off()
png("corrs.png")
levelplot(tblcorrsnum,at=c(seq(0,2,0.1)))
dev.off()
png("slopes.png")
levelplot(tblslopesnum,at=c(seq(0,2,0.1)))
dev.off()
png("ortos.png")
levelplot(tblortosnum,at=c(seq(0,2,0.1)))
dev.off()

#some labelling
#metmastsnum=unlist(sapply(metmasts$V1,function(x) as.numeric(paste(unlist(strsplit(x,"[.]"))[2]))))
metmastsnum=metmasts$V1
pairs=unlist(sapply(seq(1,N-1), function(x) {sapply(seq(x+1,N), function(y){ paste(metmastsnum[x],"/",metmastsnum[y],sep="")})}))

rownames(tblmeans)=pairs
rownames(tblmeansnum)=pairs
print((tblmeansnum))
print((tblcorrsnum))

print(head(tblmeansnum))
print(head(tblcorrsnum))
rownames(tblcorrs)=pairs
rownames(tblcorrsnum)=pairs
rownames(tblslopes)=pairs
rownames(tblslopesnum)=pairs
rownames(tblcorrs)=pairs
rownames(tblortosnum)=pairs
#EXPORT ASC
write.table(format(tblmeansnum, digits=2, scientific=F),'speedup.ratio.asc',row.names=TRUE,col.names=TRUE,quote=FALSE)
write.table(format(tblcorrsnum, digits=2, scientific=F),'speedup.correlation.asc',row.names=TRUE,col.names=TRUE,quote=FALSE)
write.table(format(tblslopesnum, digits=2, scientific=F),'speedup.linear.asc',row.names=TRUE,col.names=TRUE,quote=FALSE)
write.table(format(tblortosnum, digits=2, scientific=F),'speedup.ortho.all.asc',row.names=TRUE,col.names=TRUE,quote=FALSE)


#unifying dataframes
df=data.frame(tblslopesnum[,25],tblmeansnum[,25],tblcorrsnum[,25],tblortosnum[,25])
colnames(df)=c("Slopes","Ratio","Correlations","OLR")
df$order=seq(1,N)
df$pair=rownames(df)

melted=melt(df,id.vars=c("order","pair"))
ggplot(melted)+geom_line(aes(pair,value,color=variable,group=variable))+xlab("pair")+ylab("coef")

meltedmeans=melt(tblmeansnum)
meltedmeans$var="Ratio"
meltedcorrs=melt(tblcorrsnum)
meltedcorrs$var="Correlation"
meltedslopes=melt(tblslopesnum)
meltedslopes$var="Slopes"
meltedortos=melt(tblortosnum)
meltedortos$var="OLR"

tmp=rbind(meltedcorrs,meltedmeans)
kk=rbind(tmp,meltedslopes)
meltedall=rbind(kk,meltedortos)
colnames(meltedall)=c("pairs","sector","value","var")
#IN CASE IT IS INVERTED meltedall[meltedall$var == "Ratio","value"]=1/meltedall[meltedall$var == "MeansCoef","value"]
ggplot(meltedall)+geom_line(aes(pairs,value,color=var,group=var))+xlab("pair")+ylab("coef")+facet_wrap(~sector)
meltedall[meltedall$order == i,"freq"]=frequencies[i]
for (i in seq(1,25)){
	meltedall[meltedall$sector == i,"freq"]=frequencies[i]
}
for (i in seq(1,25)){
	melted[melted$order == i,"freq"]=frequencies[i]
}
#label the frequency
freqlabels=data.frame(x=rep(12,25),y=rep(1.3,25),label=round(unique(meltedall$freq),2),sector=seq(1,25))
#GRAPH
png("methods-comparison.png",w=1024,h=1024)
ggplot(meltedall)+geom_line(aes(pairs,value,color=var,group=var))+geom_line(aes(pairs,value,color=var,group=var))+xlab(pairs)+ylab("coef")+facet_wrap(~sector)+geom_text(data=freqlabels,aes(x=x,y=y,label=label))+scale_y_continuous(limits = c(0.5, 1.5))
dev.off()
meltedallInverted=meltedall
meltedall[meltedall$var == "Ratio","value"]=1/meltedall[meltedall$var == "Ratio","value"]
png("methods-comparison-coefinverted.png",w=1024,h=1024)
ggplot(meltedall)+geom_line(aes(pairs,value,color=var,group=var))+geom_line(aes(pairs,value,color=var,group=var))+xlab(pairs)+ylab("coef")+facet_wrap(~sector)+geom_text(data=freqlabels,aes(x=x,y=y,label=label))

dev.off()
stop()


