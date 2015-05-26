#powershell refactor, only firs 103 lines have been rewritten, work in progress
#region define a class called 'Customer'
$CustomerClass = new-object psobject -Property @{
   arrivaldate = $null
   servicestart = $null
   servicetime = $null
   serviceenddate = $null
   wait = $null
}

function CustomerClass {
    param(
          [Parameter(Mandatory=$false)]
          [String]$arrivaldate,
          [Parameter(Mandatory=$false)]
          [string]$servicestart,
          [Parameter(Mandatory=$false)]
          #[ValidateSet('Small','Medium','Large')]
          [String]$servicetime,
          [Parameter(Mandatory=$false)]
          [string]$ServiceEndDate,
          [Parameter(Mandatory=$false)]
          [string]$wait
    )
    $customer = $CustomerClass.psobject.copy()
    $customer.arrivaldate = $arrival_date
    $customer.servicestart = $service_start_date
    $customer.servicetime = $servicetime
    $customer.serviceenddate = $self.service_start_date + $self.service_time #$ServiceEndDate
    $customer.wait = $wait
    $customer
}

#$bella = CustomerClass -arrivaldate arrdte -servicestart svcst -servicetime svctm -ServiceEndDate svcenddt -wait waiting
#$bella
#endregion

#region a simple function to sample from negative exponential
#powershell has no analog to random.expovariate(lambd) so I hacked together somthing crude that is about 95% as accurate

function GetUniform #GetUint
{
    Return Get-Random -Minimum -0.00 -Maximum 1
}

# Get exponential random sample with specified mean
function GetExponential_SpecMean{
param([double]$mean)

    if ($mean -le 0.0)
    {
                Write-Host "Mean must be positive. Received $mean."
                #throw new ArgumentOutOfRangeException(msg);
            }
    $a = GetExponential
    $R = $mean * $a
    Return $R
}

# Get exponential random sample with mean 1
function GetExponential
{
    $x = GetUniform
    Return -[math]::log10(1-$x) # -Math.Log( GetUniform() );
}

function neg_exp{
param([double]$mean)
GetExponential_SpecMean 3}
#endregion neg_exp

function QSim{
#intialize clock
$t=0

#Initialize empty list to hold all data
$customers = @()

#----------------------------------
#The actual simulation happens here:

    while($t -lt $simulation_time){
        #calculate arrival date and service time for new customer
        if($customers.count -eq 0){
            $arrival_date = neg_exp 3
            $service_start_date = $arrival_date
            }
        else
            {
            $arrival_date = neg_exp 3
            $max = ($customers | measure-object -Property arrivaldate -maximum).maximum 
            $service_start_date = $max}
        $service_time = $mu
        
        #create new customer
        $customers += $customer = CustomerClass -arrivaldate $arrival_date -servicestart $service_start_date -servicetime $service_time

        #increment clock till next end of service
        $t = $arrival_date

#----------------------------------

    #calculate summary statistics



}
	#calculate summary statistics
	Waits=[a.wait for a in Customers]
	Mean_Wait=sum(Waits)/len(Waits)

	Total_Times=[a.wait+a.service_time for a in Customers]
	Mean_Time=sum(Total_Times)/len(Total_Times)

	Service_Times=[a.service_time for a in Customers]
	Mean_Service_Time=sum(Service_Times)/len(Service_Times)

	Utilisation=sum(Service_Times)/t

	#output summary statistics to screen
	print ""
	print "Summary results:"
	print ""
	print "Number of customers: ",len(Customers)
	print "Mean Service Time: ",Mean_Service_Time
	print "Mean Wait: ",Mean_Wait
	print "Mean Time in System: ",Mean_Time
	print "Utilisation: ",Utilisation
	print ""

	#prompt user to output full data set to csv
	if input("Output data to csv (True/False)? "):
		outfile=open('MM1Q-output-(%s,%s,%s).csv' %(lambd,mu,simulation_time),'wb')
		output=csv.writer(outfile)
		output.writerow(['Customer','Arrival_Date','Wait','Service_Start_Date','Service_Time','Service_End_Date'])
		i=0
		for customer in Customers:
			i=i+1
			outrow=[]
			outrow.append(i)
			outrow.append(customer.arrival_date)
			outrow.append(customer.wait)
			outrow.append(customer.service_start_date)
			outrow.append(customer.service_time)
			outrow.append(customer.service_end_date)
			output.writerow(outrow)
		outfile.close()
	print ""
	return
