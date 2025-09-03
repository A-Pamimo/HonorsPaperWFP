/* *************************************************************************** *
*				WFP RAM rCARI Validation Study - Iraq						   * 
*																 			   *
*  PURPOSE:  			Create Stata Markdown								   *
*  DATE:  				Mar 30, 2023										   *
*  WRITEN BY:  			Nicole Wu [nicole.wu@wfp.org]						   *
*  LATEST UPDATE: 		Mar 30, 2023										   *
*		  																	   *
********************************************************************************

	** REQUIRES:	${}/.dta

	** CREATES:		${}/.dta
	
*******************************************************************************/

	* Tell Stata where to find the relevant programs	
	whereis pdflatex 			"/Library/TeX/texbin/pdflatex"
	whereis pandoc 				"/usr/local/bin/pandoc"
	
	* Copy the Stata style to the same folder as the markdown file to compile in PDF
	* cd "${paper}"
	* copy https://www.stata-journal.com/production/sjlatex/stata.sty 	stata.sty
		
	markstat using "${paper}/Iraq_rCARI_Validation.stmd", docx
	// pdf docx slides beamer mathjax bibliography srict nodo nor keep
	
*============================== THE END =======================================*
