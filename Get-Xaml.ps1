Function Get-Xaml
{
[CmdletBinding()]

Param(
	[Parameter(Mandatory=$True,Position=1)]
	[String]$XamlPath
)
	#Add WPF and Windows Forms assemblies
	Try
	{
		Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms -ErrorAction Stop
	} 
	Catch 
	{
		Throw "Failed to load Windows Presentation Framework assemblies."
	}

    #Load Xaml file
	[Array]$XAML = Get-Content -Path $XamlPath

    #Remove the crap
    [XML]$XAML=$XAML | ForEach { $_ -replace [RegEx]"x.Class.+|mc.Ignorable.+|xmlns.(local|mc|d).+|x:",''}


	#Create the XAML reader using a new XML node reader
	$Global:XAMLGUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $XAML))
		
	#Create hooks to each named object in the XAML
	$XAML.SelectNodes("//*[@Name]") | ForEach {
		Set-Variable -Name ($_.Name) -Value $Global:XAMLGUI.FindName($_.Name) -Scope Global
	}
}

[String]$XAML1 = 'MainWindow.xaml'

#Load objects from GUI
Get-Xaml -XamlPath $XAML1

#Set up Events
$btnButton.add_Click({
    $txtText.Text = "You clicked the button"
    $txtText.Height = '100'
})


#Load GUI
$XAMLGUI.ShowDialog() | Out-Null