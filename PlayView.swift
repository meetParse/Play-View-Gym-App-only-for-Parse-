//
//  PlayView.swift
//  My-Gym
//
//  Created by Rahul  MAC on 30/10/17.
//  Copyright © 2017 Variance. All rights reserved.
//

import UIKit
import YouTubePlayer
import Parse
import Mixpanel
import SDWebImage

class PlayView: UIViewController , YouTubePlayerDelegate  , UIScrollViewDelegate , UITableViewDataSource , UITableViewDelegate ,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var TblView: UITableView!
    @IBOutlet var LblName: UILabel!
    @IBOutlet var PlayVdo: YouTubePlayerView!
    @IBOutlet weak var btnsave: UIButton!
    @IBOutlet weak var saveBtnView: UIView!
    
    var SelectedVideoURL = String()
    var SelectedVdoObjId = String()
    var SelectedVdoName = String()
    var FollowOrNot = String()
    var SavedOrNot = String()
    var strCreateSeriesVideoName,strStaticVideoSeriesLbl : String!
    var StrFollowBtnId = NSString()
    var InfluencerUrlSite = String()
    var videoObjectId = String()
    
    var ArrVdoAuthor = NSMutableArray()
    var ArrNameFrmVdo = NSMutableArray()
    var ArrProfilePicFrmVdo = NSMutableArray()
    var ArrVdoAuthorObjId = NSMutableArray()
    var ArrVdoPlayList = NSMutableArray()
    var ArrVdoLocation = NSMutableArray()
    var ArrVdoTimestamps = NSMutableArray()
    var ArrVdoSongs = NSMutableArray()
    var ArrVdoSongsVals = NSMutableArray()
    var ArrVdoObjId = NSMutableArray()
    var ArrDescription = NSMutableArray()
    var ArrCollabsObjId = NSMutableArray()
    var ArrVdoSeriesVdotitle = NSMutableArray()
    
    var isActivityPage = NSString()
 
    var videoFeaturedImgeData = NSMutableArray()
    var videoFeaturedUrl = NSMutableArray()
    
    var ArrCollabs = NSMutableArray()
    var ArrCollabsName = NSMutableArray()

    var ArrImagesaveID = NSMutableArray()
    var ArrImagesaveExistingID = NSMutableArray()
    
    var ArrsaveGymsObjID = NSMutableArray()
    var ArrHideIndex = NSMutableArray()
    
    let imageView = UIImageView()
    let reachability = Reachability()!
 
    var arrVdoEmbed = NSMutableArray()
    var arrVdoNameDesc = NSMutableArray()
    var arrVdoUpdatedTime  = NSMutableArray()
    var arrVdoMyGymObjId = NSMutableArray()
    
    var ArrTempVdoViewsCount = NSMutableArray()
    var ArrVideoURL = NSMutableArray()
    
    var arrApparelDataModel = [ApparelModel]()
    var arrGymDataModel = [ApparelModel]()
    var arrSpplmtDataModel = [ApparelModel]()
    var arrVdoProductionDataModel = [ApparelModel]()
    var arrAccessoriesDataModel = [ApparelModel]()
    var arrSponsorsDataModel = [ApparelModel]()
    var arrMealprepDataModel = [ApparelModel]()
    var arrFoodCompanyDataModel = [ApparelModel]()
    var arrEquipementsDataModel = [ApparelModel]()
    var arrCoachingDataModel = [ApparelModel]()
    var arrVdoDataModel = [VideosCellModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewDidLayoutSubviews() {
        if reachability.connection == .none {
            imageView.frame = CGRect(x: PlayVdo.frame.origin.x, y: PlayVdo.frame.origin.y, width: PlayVdo.frame.size.width, height: PlayVdo.frame.size.height)
            if isActivityPage == "YES"{
                let urlString = "https://i.ytimg.com/vi/\(SelectedVdoObjId)/maxresdefault.jpg"
                imageView.sd_setImage(with: URL(string: "\(urlString)"), placeholderImage: UIImage(named: "VideoDefaultImg.png"))
            } else{
                imageView.sd_setImage(with: URL(string: "\(SelectedVideoURL)"), placeholderImage: UIImage(named: "VideoDefaultImg.png"))
            }
            view.addSubview(imageView)
            saveBtnView.frame = CGRect(x: PlayVdo.frame.origin.x, y: PlayVdo.frame.origin.y+40, width: saveBtnView.frame.size.width, height: saveBtnView.frame.size.height)
            imageView.setNeedsLayout()
            imageView.layoutIfNeeded()
            imageView.addSubview(saveBtnView)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setUpView() {
        Mixpanel.mainInstance().identify(
            distinctId: Mixpanel.mainInstance().distinctId)
        Mixpanel.mainInstance().track(event: "PlayVideo")
        
        TblView.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.isHidden = false
        
        TblView.estimatedRowHeight = 100
        TblView.rowHeight = UITableViewAutomaticDimension
        btnsave.layer.masksToBounds=true
        btnsave.layer.cornerRadius=5.0
        btnsave.setTitle(SavedOrNot, for: UIControlState.normal)
        
        if SavedOrNot=="SAVED"{
            btnsave.backgroundColor = UIColor .gray
        } else{
            self.btnsave.backgroundColor = Utility().hexStringToUIColor(hex: "48A3D1")
        }
        
        if reachability.connection != .none {
            PlayVdo.playerVars = ["playsinline": 1 as AnyObject  ,  "showinfo": 0 as AnyObject]
            PlayVdo.loadVideoID(SelectedVdoObjId)
            PlayVdo.play()
        }
        
        LblName.text = SelectedVdoName
        VideosDetailAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserAPI()
        SaveImageListAPI()
    }
    
    @IBAction func BtnBack(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 19 +  self.arrVdoEmbed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "InfluencerCell", for: indexPath as IndexPath)
            let BtnFollowing = cell.contentView.viewWithTag(123) as! UIButton
            BtnFollowing.addTarget(self, action: #selector(BtnFollowing(_:)), for: .touchUpInside)
            BtnFollowing.layer.cornerRadius=5.0
            BtnFollowing.layer.masksToBounds=true
            BtnFollowing.setTitle(FollowOrNot, for: UIControlState .normal)
            
            if FollowOrNot == "FOLLOWING"{
                BtnFollowing.backgroundColor = UIColor .gray
            } else{
                BtnFollowing.backgroundColor =  Utility().hexStringToUIColor(hex: "48A3D1")
            }
            
            if(ArrNameFrmVdo.count>0){
                let lbl23 = cell.contentView.viewWithTag(101) as! UILabel
                lbl23.text = ArrNameFrmVdo[indexPath.row] as? String
            }
            if(ArrProfilePicFrmVdo.count>0){
                let imgVw = cell.contentView.viewWithTag(2) as! UIImageView
                let userPicture = ArrProfilePicFrmVdo[indexPath.row] as? PFFile
                if (userPicture?.value(forKey: "url") as? String) != nil {
                    let url = userPicture?.value(forKey: "url") as? String
                    imgVw.sd_setImage(with: URL(string: "\(url!)"))
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell
        }
            
        else if indexPath.row == 1 {
            let cell2:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath as IndexPath)
            if(ArrVdoLocation.count>0){
                let lbl = cell2.contentView.viewWithTag(6) as! UILabel
                lbl.text = ArrVdoLocation[0] as? String
            }
            return cell2
        }
            
        else if indexPath.row == 2 {
            let cell9:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "LblCell", for: indexPath as IndexPath)
            if self.ArrDescription.count>0{
                let lbl = cell9.contentView.viewWithTag(240) as! UILabel
                lbl.text = ArrDescription[0] as? String
            }
            return cell9
        }
            
        else if indexPath.row == 3 {
            let cell4:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TimestampCell", for: indexPath as IndexPath)
            if(ArrVdoTimestamps.count>0){
                let lbl = cell4.contentView.viewWithTag(9) as! UILabel
                lbl.text = ArrVdoTimestamps[0] as? String
            }
            return cell4
        }
            
        else if indexPath.row == 4 {   //Show in Collection View
            let cell5:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CollabsCell", for: indexPath as IndexPath)
            return cell5
        }
            
        else if indexPath.row == 5 { //Show in Collection View
            let cell3:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "GymCell", for: indexPath as IndexPath)
            return cell3
        }
            
        else if indexPath.row == 6 {
            let cell3:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ApparelCell", for: indexPath as IndexPath)
            return cell3
        }
            
        else if indexPath.row == 7 {
            let cell3:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SupplementCell", for: indexPath as IndexPath)
            return cell3
        }
            
        else if indexPath.row == 8 {
            let cell3:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "EquipementCell", for: indexPath as IndexPath)
            return cell3
        }
            
        else if indexPath.row == 9 {
            let cell8:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "VdoProdCell", for: indexPath as IndexPath)
            return cell8
        }
            
        else if indexPath.row == 10 {
            let cell8:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "sponsorCell", for: indexPath as IndexPath)
            return cell8
        }
            
        else if indexPath.row == 11 {
            let cell8:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "mealPrepCell", for: indexPath as IndexPath)
            return cell8
        }
            
        else if indexPath.row == 12 {
            let cell8:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "foodcompCell", for: indexPath as IndexPath)
            return cell8
        }
            
        else if indexPath.row == 13 {
            let cell8:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "coachCell", for: indexPath as IndexPath)
            return cell8
        }
            
        else if indexPath.row == 14 {
            let cell8:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "accesoriesCell", for: indexPath as IndexPath)
            return cell8
        }
            
        else if indexPath.row == 15 {
            let cell6:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "VdoSongCell", for: indexPath as IndexPath)
            if self.ArrVdoSongs.count>0{
                let lbl = cell6.contentView.viewWithTag(220) as! UILabel
                lbl.text = ArrVdoSongs[0] as? String
            }
            
            return cell6
        }
            
        else if indexPath.row == 16 {   //Show in Collection View
            let cell7:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeaturedCell", for: indexPath as IndexPath)
            return cell7
        }
            
        else if indexPath.row == 17 {   //Show in Collection View
            let cell1:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "CreatelifeCell", for: indexPath as IndexPath)
            let lblCreateVideoName = cell1.contentView.viewWithTag(1501) as? UILabel
            let lblstaticName = cell1.contentView.viewWithTag(1502) as? UILabel
            lblCreateVideoName?.text = strCreateSeriesVideoName
            lblstaticName?.text = strStaticVideoSeriesLbl
            return cell1
        }
            
        else if indexPath.row == 18 {   //Static Lable
            let cell7:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "staticVdoCell", for: indexPath as IndexPath)
            return cell7
        }
            
        else  {   //Show in Collection View
            let cell9:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "VdoCell", for: indexPath as IndexPath)
            let view = cell9.contentView.viewWithTag(20) as! UIImageView
            let lblViewsCount = cell9.contentView.viewWithTag(236) as! UILabel
            let lblName = cell9.contentView.viewWithTag(117) as! UILabel
            let lblDesc = cell9.contentView.viewWithTag(118) as! UILabel
            let imgVw = cell9.contentView.viewWithTag(116) as! UIImageView
            let lblTime = cell9.contentView.viewWithTag(23) as! UILabel
            
            lblName.text = ArrNameFrmVdo[0] as? String
            
            if self.arrVdoDataModel .count > 0 {
                let cellAttribute = self.arrVdoDataModel[indexPath.row - 19]
           
                view.layer.cornerRadius = 5
                view.layer.masksToBounds = true
               
                if indexPath.row-19 >= self.ArrVideoURL.count{
                    view.image = UIImage(named: "VideoDefaultImg.png")
                    lblViewsCount.text = "0 Views"
                } else{
                    if let embed = cellAttribute.Embed {
                    view.sd_setImage(with: URL(string: embed))
                    let string = embed
                    if string == "None"{
                        view.image = UIImage(named: "VideoDefaultImg.png")
                        lblViewsCount.text = "0 Views"
                    } else{
                        let indexesTitle = ArrVideoURL.enumerated().filter {
                            ($0.element as AnyObject).localizedCaseInsensitiveContains(string as String)
                            }.map{$0.offset}
                        for i in indexesTitle{
                            let strVideoUrl  = self.ArrVideoURL[i]
                            if ArrTempVdoViewsCount.at(index: i) != nil {
                                lblViewsCount.text = self.ArrTempVdoViewsCount[i] as? String
                            }
                            view.sd_setImage(with: URL(string: (strVideoUrl as! NSString) as String))
                        }
                    }
                }
                }
            
                if let Desc = cellAttribute.Description {
                    lblDesc.text = Desc
                }
                
                imgVw.image = nil
                let userPicture = ArrProfilePicFrmVdo[0] as? PFFile
                if (userPicture?.value(forKey: "url") as? String) != nil {
                    let url = userPicture?.value(forKey: "url") as? String
                    imgVw.sd_setImage(with: URL(string: "\(url!)"))
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
                
                if let time = cellAttribute.UpdatedTime {
                    let strFinalTimeDuration = Utility().GetTimeDuration(FromTime: time)
                    lblTime.text = strFinalTimeDuration
                }
            }
           
            return cell9
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main" , bundle: nil)
        if indexPath.row == 0{
            let vc = storyboard.instantiateViewController(withIdentifier: "InfluencersProfileVC") as! InfluencersProfileVC
            vc.SelectedClassNames = "Influencers"
            vc.FollowOrNot = FollowOrNot
            vc.SelectedObjId = (self.ArrVdoAuthorObjId[0] as! NSString) as String
            vc.SelectedName = (self.ArrNameFrmVdo[0] as! NSString) as String
            self.present(vc, animated: true, completion: nil)
        }
        
        if indexPath.row == 15 {
            if self.ArrVdoSongsVals.count>0{
                var StrUrl = NSString()
                StrUrl  = (ArrVdoSongsVals[0]  as? NSString)!
                if StrUrl != " "{
                    if let url = URL(string: "\(StrUrl)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
        
        else if indexPath.row >= 19 {
            let storyboard = UIStoryboard(name: "Main" , bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PlayView") as! PlayView
            if ArrsaveGymsObjID .contains(ArrVdoObjId[indexPath.row-19]){
                vc.SavedOrNot = "SAVED"
            } else{
                vc.SavedOrNot = "SAVE"
            }
            vc.SelectedVideoURL = (ArrVideoURL[indexPath.row-19] as? String)!
            vc.FollowOrNot = FollowOrNot
            vc.SelectedVdoObjId = (arrVdoEmbed[indexPath.row-19] as? String)!
            vc.SelectedVdoName = (arrVdoNameDesc[indexPath.row-19] as? String)!
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(self.ArrHideIndex.count>0){
            if(self.ArrHideIndex .contains(indexPath.row)){
                return 0
            }
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell , forRowAt indexPath: IndexPath) {
        if reachability.connection != .none {
            let lastRowIndex = tableView.numberOfRows(inSection: 0)
            if (indexPath.row == lastRowIndex - 3) {
                self.VideosAPI()
            }
        }
    }
    
//MARK: - Button Following
    @objc func BtnFollowing(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.TblView)
        let indexPath = self.TblView.indexPathForRow(at:buttonPosition)
        StrFollowBtnId = ArrVdoAuthorObjId[(indexPath?.row)!] as! NSString
        
        let cell = TblView.cellForRow(at: indexPath!)
        let BtnFollowing = cell?.contentView.viewWithTag(123) as! UIButton
        let buttonTitle = sender.title(for: .normal)
        
        if buttonTitle=="FOLLOWING"{
            PFCloud.callFunction(inBackground: "followInfluencer", withParameters: ["influencerId": StrFollowBtnId as String , "remove":"yes"]) {
                (ratings, error) in
                if !(error != nil) {
                    BtnFollowing.setTitle("FOLLOW", for: UIControlState .normal)
                    BtnFollowing.backgroundColor = Utility().hexStringToUIColor(hex: "48A3D1")
                }
                else{
                    print(error as Any)
                }
            }
        }
        else{
            PFCloud.callFunction(inBackground: "followInfluencer", withParameters: ["influencerId": StrFollowBtnId as String]) {
                (ratings, error) in
                if !(error != nil) {
                    Mixpanel.mainInstance().identify(
                        distinctId: Mixpanel.mainInstance().distinctId)
                    Mixpanel.mainInstance().track(event: "Follow")
                    
                    BtnFollowing.setTitle("FOLLOWING", for: UIControlState .normal)
                    BtnFollowing.backgroundColor = UIColor .gray
                }
                else{
                    print(error as Any)
                }
            }
        }
    }
    
// MARK: - Video Details    Web Service (ALL)
    func VideosDetailAPI() ->Void {
        let query = PFQuery(className:"Videos")
        query.order(byDescending: "createdAt")
        query.whereKey("embed", contains: SelectedVdoObjId)
        query.includeKey("influencer")
        query.includeKey("gym")
        query.includeKey("videoProductions")
        query.includeKey("videos")
        query.includeKey("featureds")
        query.includeKey("collabs")
        query.includeKey("apparels")
        query.includeKey("supplements")
        query.includeKey("equipments")
        query.includeKey("foodCompany")
        query.includeKey("mealPrep")
        query.includeKey("sponsor")
        query.includeKey("accessories")
        query.includeKey("coaching")
        query.whereKey("active", equalTo: true)
        
        if reachability.connection == .none {
            query.cachePolicy = PFCachePolicy.cacheOnly
        }
        else{
            if query.hasCachedResult == true{
                query.cachePolicy = PFCachePolicy.cacheThenNetwork
                query.maxCacheAge = 0
            } else{
                query.cachePolicy = PFCachePolicy.networkOnly
            }
        }
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    self.ArrVdoObjId .add(object.objectId as Any)
                    
//----------------------------------
                    var StrAvail1 = NSArray()
                    StrAvail1 = object.allKeys as NSArray
                    
//----------------------------------
                    
                    if(StrAvail1 .contains("description")){
                        let jsonCoordinatesString: String = object["description"] as! String
                        let whitespaceAndNewlineCharacterSet = NSCharacterSet.newlines
                        let components = jsonCoordinatesString.components(separatedBy: whitespaceAndNewlineCharacterSet)
                        let result = components.joined(separator: "")
                        self.ArrDescription .add(result)
                        self.countIncreaseMethod()
                    }
                    else{
                        self.ArrHideIndex .add(2)
                        self.countIncreaseMethod()
                    }
                    
                    if(StrAvail1 .contains("influencer")){
                        //For Getting the Pointer Data (From Video Tabel to Get Influencers Tabel Data)
                        let author = object.value(forKey: "influencer") as! PFObject
                        self.ArrVdoAuthor .add(author)
                        self.ArrVdoAuthorObjId .add(author.objectId as Any)
                        var Str = String()
                        Str = author.objectId! as String
                        
                        if let author1 = objects{
                            for photo in author1 {
                                if let parentPointer:PFObject = photo["influencer"] as? PFObject{
                                    self.countIncreaseMethod()
                                    if let strUrl  = parentPointer["urlSite"] as? String{
                                        self.InfluencerUrlSite = strUrl
                                    } else{
                                        self.InfluencerUrlSite = ""
                                    }
                                    
                                    if(parentPointer.objectId == Str){
                                        if let name = parentPointer.value(forKey: "name") as? String {
                                            self.ArrNameFrmVdo .add(name)
                                        } else{
                                            self.ArrHideIndex .add(0)
                                        }
                                        if let userPicture = parentPointer.value(forKey: "image") as? NSMutableArray {
                                            for PFFlie in userPicture {
                                                self.self.ArrProfilePicFrmVdo.add(PFFlie)
                                            }
                                        } else{
                                            self.ArrProfilePicFrmVdo .add("")
                                        }
                                        break
                                    }
                                }
                            }
                        }
                    }
                    else{
                        self.ArrVdoAuthor .add("None")
                        self.ArrHideIndex .add(0)
                        self.countIncreaseMethod()
                    }
                    
//------------------------------------------
                    
                    if(StrAvail1 .contains("location")){
                        let location = object.value(forKey: "location") as Any
                        self.ArrVdoLocation .add(location)
                        self.countIncreaseMethod()
                    } else{
                        self.ArrHideIndex .add(1)
                        self.countIncreaseMethod()
                    }
                    
//-------------------------------
                    
                    if(StrAvail1 .contains("accessories")){
                        let Equipement:PFRelation = object.relation(forKey: "accessories")
                        let queryEquipement :PFQuery   = Equipement.query()
                        queryEquipement.includeKey("influencerCodes")
                        queryEquipement.order(byDescending: "createdAt")
                        queryEquipement.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            queryEquipement.cachePolicy = PFCachePolicy.cacheOnly
                        } else{
                            queryEquipement.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        queryEquipement.findObjectsInBackground { (objects1: [PFObject]?, error1: Error?) -> Void in
                            if error1 == nil {
                                for object2 in objects1! {
                                    let accessoriesData  = ApparelModel()
                                    
                                    if let objectId = object2.value(forKeyPath: "objectId") as? String {
                                        accessoriesData.ObjId = objectId
                                    }
                                    else{
                                        accessoriesData.ObjId = ""
                                    }
                                    if let name = object2.value(forKey: "name") as? String {
                                        accessoriesData.name = name
                                    } else{
                                        accessoriesData.name = ""
                                    }
                                    
                                    if let influencerCodes = object2.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData.add(code!)
                                                    }
                                                }
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                            accessoriesData.Code = (arrTempCodeData.lastObject! as? String)
                                        } else{
                                            accessoriesData.Code = ""
                                        }
                                    } else{
                                        accessoriesData.Code = ""
                                    }
                                    
                                    if let userPicture = object2.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            accessoriesData.image = (PFFlie as? PFFile)
                                        }
                                    } else{
                                        accessoriesData.image = "" as AnyObject
                                    }
                                    self.arrAccessoriesDataModel.append(accessoriesData)
                                    self.countIncreaseMethod()
                                }
                                DispatchQueue.main.async {
                                    self.arrAccessoriesDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrAccessoriesDataModel .count == 0 {
                                        self.ArrHideIndex .add(14)
                                        self.countIncreaseMethod()
                                    }
                                }
                            }  else{
                                self.ArrHideIndex .add(14)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(14)
                        self.countIncreaseMethod()
                    }
                    
//-------------------------------
                    
                    if(StrAvail1 .contains("coaching")){
                        let Equipement:PFRelation = object.relation(forKey: "coaching")
                        let queryEquipement :PFQuery   = Equipement.query()
                        queryEquipement.includeKey("influencerCodes")
                        queryEquipement.order(byDescending: "createdAt")
                        queryEquipement.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            queryEquipement.cachePolicy = PFCachePolicy.cacheOnly
                        } else{
                            queryEquipement.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        queryEquipement.findObjectsInBackground { (objects1: [PFObject]?, error1: Error?) -> Void in
                            if error1 == nil {
                                for object2 in objects1! {
                                    let Coachdata = ApparelModel()
                                    
                                    if let objectId = object2.value(forKeyPath: "objectId") as? String {
                                        Coachdata.ObjId = objectId
                                    } else{
                                        Coachdata.ObjId = ""
                                    }
                                    
                                    if let name = object2.value(forKey: "name") as? String {
                                        Coachdata.name = name
                                    } else{
                                        Coachdata.name = ""
                                    }
                                    
                                    if let influencerCodes = object2.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData.add(code!)
                                                    }
                                                }
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                            Coachdata.Code = (arrTempCodeData.lastObject! as? String)
                                        } else{
                                            Coachdata.Code = ""
                                        }
                                    } else{
                                        Coachdata.Code = ""
                                    }
                                    
                                    if let userPicture = object2.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            Coachdata.image = (PFFlie as? PFFile)
                                        }
                                    } else{
                                        Coachdata.image = "" as AnyObject
                                    }
                                    self.arrCoachingDataModel.append(Coachdata)
                                    self.countIncreaseMethod()
                                }
                                DispatchQueue.main.async {
                                     self.arrCoachingDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrCoachingDataModel .count == 0 {
                                        self.ArrHideIndex .add(13)
                                        self.countIncreaseMethod()
                                    }
                                }
                            }
                            else{
                                self.ArrHideIndex .add(13)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(13)
                        self.countIncreaseMethod()
                    }
                    
//------------------------------------------
                    
                    if(StrAvail1 .contains("gyms")){
                        let gym:PFRelation = object.relation(forKey: "gyms")
                        let query12:PFQuery = gym.query()
                        query12.includeKey("influencerCodes")
                        query12.order(byDescending: "createdAt")
                        query12.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            query12.cachePolicy = PFCachePolicy.cacheOnly
                        }
                        else{
                            query12.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        query12.findObjectsInBackground { (objects12: [PFObject]?, error12: Error?) -> Void in
                            if error12 == nil {
                                for object3 in objects12! {
                                    let GymsData = ApparelModel()
                                    GymsData.ObjId = object3.objectId
                                    
                                    if let name = object3.value(forKey: "name") as? String {
                                        GymsData.name = name
                                    } else{
                                        GymsData.name = ""
                                    }
                                    
                                    if let influencerCodes = object3.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData.add(code!)
                                                    }
                                                }
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                            GymsData.Code = (arrTempCodeData.lastObject! as? String)
                                        } else{
                                            GymsData.Code = ""
                                        }
                                    }
                                    else{
                                        GymsData.Code = ""
                                    }
                                    
                                    if let userPicture = object3.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            GymsData.image = (PFFlie as? PFFile)
                                        }
                                    } else{
                                        GymsData.image = "" as AnyObject
                                    }
                                    self.arrGymDataModel.append(GymsData)
                                    self.countIncreaseMethod()
                                }
                                
                                DispatchQueue.main.async {
                                    self.arrGymDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrGymDataModel.count == 0{
                                        self.ArrHideIndex .add(5)
                                        self.countIncreaseMethod()
                                    }
                                }
                            } else{
                                self.ArrHideIndex .add(5)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(5)
                        self.countIncreaseMethod()
                    }
                    
//------------------------------------------
                    
                    if(StrAvail1 .contains("timestamp")){
                        let timestamp = object.value(forKey: "timestamp") as Any
                        if timestamp as! String == ""{
                            self.ArrHideIndex .add(3)
                            self.countIncreaseMethod()
                        } else{
                            self.ArrVdoTimestamps .add(timestamp)
                            self.countIncreaseMethod()
                        }
                    } else{
                        self.ArrHideIndex .add(3)
                        self.countIncreaseMethod()
                    }
                    
//------------------------------------------
                    //For Getting Relation Based Data
                    if(StrAvail1 .contains("collabs")){
                        let relation : PFRelation =  object.relation(forKey: "collabs")
                        let querycollabs = relation.query()
                        querycollabs.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            querycollabs.cachePolicy = PFCachePolicy.cacheOnly
                        } else{
                            querycollabs.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        querycollabs.findObjectsInBackground { (objectscollabs: [PFObject]?, error: Error?) -> Void in
                            if error == nil {
                                for object12 in objectscollabs! {
                                    let objectId = object12.value(forKeyPath: "objectId") as Any
                                    self.ArrCollabsObjId .add(objectId)
                                    
                                    if let name = object12.value(forKey: "name") as? String {
                                        self.ArrCollabsName .add(name)
                                    } else{
                                        print("collabs not contains name ")
                                    }
                                    
                                    if let userPicture = object12.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            self.ArrCollabs .add(PFFlie)
                                        }
                                    } else{
                                        print("collabs not contains image ")
                                    }
                                    self.countIncreaseMethod()
                                }
                                
                                if self.ArrCollabs .count == 0{
                                    self.ArrHideIndex .add(4)
                                    self.countIncreaseMethod()
                                }
                            }
                            else{
                                self.ArrHideIndex .add(4)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(4)
                        self.countIncreaseMethod()
                    }
                    
//----------------------------------
                    
                    if(StrAvail1 .contains("videoSong")){
                        let videoSong = object.value(forKey: "videoSong") as! NSMutableDictionary
                        for Data in videoSong{
                            var StrKeys = NSString()
                            StrKeys = Data.key as! NSString
                            
                            if StrKeys .isEqual(to: "name"){
                                self.ArrVdoSongs .add(Data.value)
                            } else{
                                self.ArrVdoSongsVals .add(Data.value)
                            }
                            self.countIncreaseMethod()
                        }
                    }
                    else{
                        self.ArrHideIndex .add(15)
                        self.countIncreaseMethod()
                    }
                    
//----------------------------------
                    
                    //For Getting Relation Based Data
                    
                    if(StrAvail1 .contains("featureds")){
                        let relation : PFRelation =  object.relation(forKey: "featureds")
                        let query123 = relation.query()
                   
                        if self.reachability.connection == .none {
                            query123.cachePolicy = PFCachePolicy.cacheOnly
                        }
                        else{
                            query123.cachePolicy = PFCachePolicy.networkOnly
                        }
                        query123.findObjectsInBackground { (objects123: [PFObject]?, error: Error?) -> Void in
                            
                            if error == nil {
                                for object12 in objects123! {
                                    var StrAvailName = NSArray()
                                    StrAvailName = object12.allKeys as NSArray
                                    
                                    if StrAvailName .contains("url"){
                                        let url = object12.value(forKey: "url") as Any
                                        self.videoFeaturedUrl .add(url)
                                    } else{
                                        self.videoFeaturedUrl .add("")
                                    }
                                    
                                    if StrAvailName .contains("image"){
                                        let userPicture = object12.value(forKey: "image")! as! NSMutableArray
                                        for PFFlie in userPicture {
                                            self.videoFeaturedImgeData .add(PFFlie)
                                        }
                                    } else{
                                        self.videoFeaturedImgeData .add("")
                                    }
                                    self.countIncreaseMethod()
                                }
                                if self.videoFeaturedUrl .count == 0{
                                    self.ArrHideIndex .add(16)
                                    self.countIncreaseMethod()
                                }
                            } else{
                                self.ArrHideIndex .add(16)
                                self.countIncreaseMethod()
                            }
                        }
                    } else{
                        self.ArrHideIndex .add(16)
                        self.countIncreaseMethod()
                    }
                    
//----------------------------------
                    
                    if(StrAvail1 .contains("videoProductions")){
                        let gym:PFRelation = object.relation(forKey: "videoProductions")
                        let query12:PFQuery = gym.query()
                        query12.includeKey("influencerCodes")
                        query12.order(byDescending: "createdAt")
                        query12.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            query12.cachePolicy = PFCachePolicy.cacheOnly
                        }
                        else{
                            query12.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        query12.findObjectsInBackground { (objects12: [PFObject]?, error12: Error?) -> Void in
                            if error12 == nil {
                                for object3 in objects12! {
                                    let VdoProdData = ApparelModel()
                                    
                                    VdoProdData.ObjId = object3.objectId
                                    
                                    if let name = object3.value(forKey: "name") as? String {
                                        VdoProdData.name = name
                                    } else{
                                         VdoProdData.name = ""
                                    }
                                    
                                    if let influencerCodes = object3.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData.add(code!)
                                                    }
                                                }
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                             VdoProdData.Code = (arrTempCodeData.lastObject! as? String)
                                        } else{
                                            VdoProdData.Code = ""
                                        }
                                    }
                                    else{
                                        VdoProdData.Code = ""
                                    }
                                    
                                    if let userPicture = object3.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            VdoProdData.image = (PFFlie as? PFFile)
                                         }
                                    } else{
                                        VdoProdData.image = "" as AnyObject
                                    }
                                    self.arrVdoProductionDataModel .append(VdoProdData)
                                    self.countIncreaseMethod()
                                }
                                DispatchQueue.main.async {
                                    self.arrVdoProductionDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrVdoProductionDataModel.count == 0{
                                        self.ArrHideIndex .add(9)
                                        self.countIncreaseMethod()
                                    }
                                }
                            } else{
                                self.ArrHideIndex .add(9)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(9)
                        self.countIncreaseMethod()
                    }
                    
//-----------------------------
                    
                    if(StrAvail1 .contains("apparels")){
                        let sponsor:PFRelation = object.relation(forKey: "apparels")
                        let query1 :PFQuery   = sponsor.query()
                        query1.includeKey("influencerCodes")
                        query1.order(byDescending: "createdAt")
                        query1.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            query1.cachePolicy = PFCachePolicy.cacheOnly
                        } else{
                            query1.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        query1.findObjectsInBackground { (objects1: [PFObject]?, error1: Error?) -> Void in
                            if error1 == nil {
                                for object2 in objects1! {
                                    let apparelData = ApparelModel()
                                    
                                    if let objectId = object2.value(forKeyPath: "objectId") as? String {
                                        apparelData.ObjId = objectId
                                    } else {
                                        apparelData.ObjId = ""
                                    }
                                    
                                    if let name = object2.value(forKey: "name") as? String {
                                        apparelData.name = name
                                    } else{
                                        apparelData.name = ""
                                    }
                                    
                                    if let influencerCodes = object2.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData.add(code!)
                                                    }
                                                }
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                            apparelData.Code = (arrTempCodeData.lastObject! as? String)
                                        } else{
                                            apparelData.Code = ""
                                        }
                                    }
                                    else{
                                        apparelData.Code = ""
                                    }
                                    
                                    if let userPicture = object2.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            apparelData.image = (PFFlie as? PFFile)
                                        }
                                    } else{
                                        apparelData.image = "" as AnyObject
                                    }
                                    self.arrApparelDataModel.append(apparelData)
                                    self.countIncreaseMethod()
                                }
                                
                                DispatchQueue.main.async {
                                    self.arrApparelDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrApparelDataModel.count == 0{
                                        self.ArrHideIndex .add(6)
                                        self.countIncreaseMethod()
                                    }
                                }
                            }
                            else{
                                self.ArrHideIndex .add(6)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(6)
                        self.countIncreaseMethod()
                    }
                    
//-----------------------------
                    
                    if(StrAvail1 .contains("supplements")){
                        let supplements:PFRelation = object.relation(forKey: "supplements")
                        let query1 :PFQuery   = supplements.query()
                        query1.includeKey("influencerCodes")
                        query1.order(byDescending: "createdAt")
                        query1.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            query1.cachePolicy = PFCachePolicy.cacheOnly
                        } else{
                            query1.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        query1.findObjectsInBackground { (objects1: [PFObject]?, error1: Error?) -> Void in
                            if error1 == nil {
                                for object2 in objects1! {
                                    let supplementData = ApparelModel()
                                    
                                    if let objectId = object2.value(forKeyPath: "objectId") as? String {
                                        supplementData.ObjId = objectId
                                    }
                                    else{
                                        supplementData.ObjId = ""
                                    }
                                    
                                    if let name = object2.value(forKey: "name") as? String {
                                        supplementData.name = name
                                    } else{
                                        supplementData.name = ""
                                    }
                                    
                                    if let influencerCodes = object2.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData.add(code!)
                                                    }
                                                }
                                                
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                            supplementData.Code = (arrTempCodeData.lastObject! as? String)
                                        }else{
                                            supplementData.Code = ""
                                        }
                                    }
                                    else{
                                        supplementData.Code = ""
                                    }
                                    
                                    if let userPicture = object2.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            supplementData.image = (PFFlie as? PFFile)
                                        }
                                    }  else{
                                        supplementData.image = "" as AnyObject
                                    }
                                    self.arrSpplmtDataModel .append(supplementData)
                                    self.countIncreaseMethod()
                                }
                                
                                DispatchQueue.main.async {
                                    self.arrSpplmtDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrSpplmtDataModel.count == 0{
                                        self.ArrHideIndex .add(7)
                                        self.countIncreaseMethod()
                                    }
                                }
                            }
                            else{
                                self.ArrHideIndex .add(7)
                                self.countIncreaseMethod()
                            }
                        }
                    }  else{
                        self.ArrHideIndex .add(7)
                        self.countIncreaseMethod()
                    }
                    
//-------------------------------
                    
                    if(StrAvail1 .contains("mealPrep")){
                        let Equipement:PFRelation = object.relation(forKey: "mealPrep")
                        let queryEquipement :PFQuery   = Equipement.query()
                        queryEquipement.includeKey("influencerCodes")
                        queryEquipement.order(byDescending: "createdAt")
                        queryEquipement.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            queryEquipement.cachePolicy = PFCachePolicy.cacheOnly
                        } else{
                            queryEquipement.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        queryEquipement.findObjectsInBackground { (objects1: [PFObject]?, error1: Error?) -> Void in
                            if error1 == nil {
                                for object2 in objects1! {
                                    let mealPrepData = ApparelModel()
                                    
                                    if let objectId = object2.value(forKeyPath: "objectId") as? String {
                                        mealPrepData.ObjId = objectId
                                    } else {
                                         mealPrepData.ObjId = ""
                                    }
                                    
                                    if let name = object2.value(forKey: "name") as? String {
                                         mealPrepData.name = name
                                    } else{
                                         mealPrepData.name = ""
                                    }
                                    
                                    if let influencerCodes = object2.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData.add(code!)
                                                    }
                                                }
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                             mealPrepData.Code = (arrTempCodeData.lastObject! as? String)
                                        }else{
                                            mealPrepData.Code = ""
                                        }
                                    }
                                    else{
                                        mealPrepData.Code = ""
                                    }
                                    
                                    if let userPicture = object2.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            mealPrepData.image = (PFFlie as? PFFile)
                                        }
                                    } else{
                                        mealPrepData.image = "" as AnyObject
                                    }
                                    self.arrMealprepDataModel .append(mealPrepData)
                                    self.countIncreaseMethod()
                                }
                                DispatchQueue.main.async {
                                    self.arrMealprepDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrMealprepDataModel .count == 0 {
                                        self.ArrHideIndex .add(11)
                                        self.countIncreaseMethod()
                                    }
                                }
                            }
                            else{
                                self.ArrHideIndex .add(11)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(11)
                        self.countIncreaseMethod()
                    }
                    
                    
//-------------------------------
                    
                    if(StrAvail1 .contains("foodCompanies")){
                        let Equipement:PFRelation = object.relation(forKey: "foodCompanies")
                        let queryEquipement :PFQuery   = Equipement.query()
                        queryEquipement.includeKey("influencerCodes")
                        queryEquipement.order(byDescending: "createdAt")
                        queryEquipement.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            queryEquipement.cachePolicy = PFCachePolicy.cacheOnly
                        } else{
                            queryEquipement.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        queryEquipement.findObjectsInBackground { (objects1: [PFObject]?, error1: Error?) -> Void in
                            if error1 == nil {
                                for object2 in objects1! {
                                    let FoodCompData = ApparelModel()
                                    
                                    if let objectId = object2.value(forKeyPath: "objectId") as? String {
                                        FoodCompData.ObjId = objectId
                                    } else{
                                        FoodCompData.ObjId = ""
                                    }
                                    if let name = object2.value(forKey: "name") as? String {
                                        FoodCompData.name = name
                                    } else{
                                        FoodCompData.name = ""
                                    }
                                    
                                    if let influencerCodes = object2.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData.add(code!)
                                                    }
                                                }
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                            FoodCompData.Code = (arrTempCodeData.lastObject! as? String)
                                        } else{
                                            FoodCompData.Code = ""
                                        }
                                    }
                                    else{
                                        FoodCompData.Code = ""
                                    }
                                    
                                    if let userPicture = object2.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            FoodCompData.image = (PFFlie as? PFFile)
                                        }
                                    } else{
                                        FoodCompData.image = "" as AnyObject
                                    }
                                    self.arrFoodCompanyDataModel.append(FoodCompData)
                                    self.countIncreaseMethod()
                                }
                                DispatchQueue.main.async {
                                    self.arrFoodCompanyDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrFoodCompanyDataModel .count == 0 {
                                        self.ArrHideIndex .add(12)
                                        self.countIncreaseMethod()
                                    }
                                }
                            }
                            else{
                                self.ArrHideIndex .add(12)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(12)
                        self.countIncreaseMethod()
                    }
                    
                    
//------------------------
                    
                    if(StrAvail1 .contains("equipments")){
                        let Equipement:PFRelation = object.relation(forKey: "equipments")
                        let queryEquipement :PFQuery   = Equipement.query()
                        queryEquipement.order(byDescending: "createdAt")
                        queryEquipement.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            queryEquipement.cachePolicy = PFCachePolicy.cacheOnly
                        } else{
                            queryEquipement.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        queryEquipement.findObjectsInBackground { (objects1: [PFObject]?, error1: Error?) -> Void in
                            if error1 == nil {
                                for object2 in objects1! {
                                    let EquipementData = ApparelModel()
                                    
                                    if let objectId = object2.value(forKeyPath: "objectId") as? String {
                                        EquipementData.ObjId = objectId
                                    }
                                    else{
                                        EquipementData.ObjId = ""
                                    }
                                    
                                    if let name = object2.value(forKey: "name") as? String {
                                        EquipementData.name = name
                                    } else{
                                        EquipementData.name = ""
                                    }
                                    
                                    if let influencerCodes = object2.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData.add(code!)
                                                    }
                                                }
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                            EquipementData.Code = (arrTempCodeData.lastObject! as? String)
                                        } else{
                                            EquipementData.Code = ""
                                        }
                                    }
                                    else{
                                        EquipementData.Code = ""
                                    }
                                    
                                    if let userPicture = object2.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                            EquipementData.image = (PFFlie as? PFFile)
                                        }
                                    } else{
                                        EquipementData.image = "" as AnyObject
                                    }
                                    self.arrEquipementsDataModel .append(EquipementData)
                                    self.countIncreaseMethod()
                                }
                                DispatchQueue.main.async {
                                    self.arrEquipementsDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrEquipementsDataModel .count == 0 {
                                        self.ArrHideIndex .add(8)
                                        self.countIncreaseMethod()
                                    }
                                }
                            }
                            else{
                                self.ArrHideIndex .add(8)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(8)
                        self.countIncreaseMethod()
                    }
                    
//-----------------------------
                    // TO GET THE PFRELATION DATA
                    
                    if(StrAvail1 .contains("sponsors")){
                        let sponsor:PFRelation = object.relation(forKey: "sponsors")
                        let query1 :PFQuery   = sponsor.query()
                        query1.includeKey("influencerCodes")
                        query1.order(byDescending: "createdAt")
                        query1.order(byAscending: "name")
                        
                        if self.reachability.connection == .none {
                            query1.cachePolicy = PFCachePolicy.cacheOnly
                        }else{
                            query1.cachePolicy = PFCachePolicy.networkOnly
                        }
                        
                        query1.findObjectsInBackground { (objects1: [PFObject]?, error1: Error?) -> Void in
                            if error1 == nil {
                                for object2 in objects1! {
                                    let SponsorData = ApparelModel()
                                    
                                    if let objectId = object2.value(forKeyPath: "objectId") as? String {
                                        SponsorData.ObjId = objectId
                                    }
                                    else{
                                        SponsorData.ObjId = ""
                                    }
                                    if let name = object2.value(forKeyPath: "name") as? String {
                                        SponsorData.name = name
                                    } else{
                                        SponsorData.name =  ""
                                    }
                                    
                                    if let influencerCodes = object2.value(forKey: "influencerCodes") as? NSMutableArray {
                                        let arrTempCodeData = NSMutableArray()
                                        for Data in influencerCodes {
                                            if let influencer = (Data as AnyObject).value(forKey: "influencer") as? PFObject {
                                                if influencer.objectId == self.ArrVdoAuthorObjId[0] as? String {
                                                    let code = (Data as AnyObject).value(forKey: "code") as? String
                                                    if code != nil{
                                                        arrTempCodeData .add(code!)
                                                    }
                                                }
                                            }
                                        }
                                        if arrTempCodeData.count > 0 {
                                            SponsorData.Code = (arrTempCodeData.lastObject! as? String)
                                        } else{
                                             SponsorData.Code = ""
                                        }
                                    }
                                    else{
                                         SponsorData.Code = ""
                                    }
                                    
                                    if let userPicture = object2.value(forKey: "image") as? NSMutableArray {
                                        for PFFlie in userPicture {
                                             SponsorData.image  = (PFFlie as? PFFile)
                                        }
                                    } else{
                                        SponsorData.image  = "" as AnyObject
                                    }
                                    self.arrSponsorsDataModel.append(SponsorData)
                                    self.countIncreaseMethod()
                                }
                                DispatchQueue.main.async {
                                    self.arrSponsorsDataModel.sort(by: { $0.Code!.localizedCaseInsensitiveCompare($1.Code!) == ComparisonResult.orderedDescending })
                                    if self.arrSponsorsDataModel.count == 0 {
                                        self.ArrHideIndex .add(10)
                                        self.countIncreaseMethod()
                                    }
                                }
                            }
                            else{
                                self.ArrHideIndex .add(10)
                                self.countIncreaseMethod()
                            }
                        }
                    }
                    else{
                        self.ArrHideIndex .add(10)
                        self.countIncreaseMethod()
                    }
                    
//----------------------------------
                }
                
            }
            DispatchQueue.main.async {
                if self.ArrVdoAuthorObjId.count > 0 {
                    self.VideosSeriesAPI()
                    self.VideosAPI()
                }
            }
        }
    }
    
//PRAGMA MARK:-  Increase Counnt Method
    func countIncreaseMethod() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reloadTblData), object: nil)
        self.perform(#selector(self.reloadTblData), with: nil, afterDelay: 2)
    }
    
//PRAGMA MRK:- reload Tbl Data
   @objc func reloadTblData() {
        DispatchQueue.main.async {
            if self.arrVdoEmbed.count == 0{
                self.ArrHideIndex .add(18)
                self.ArrHideIndex .add(19)
            }
            
            let collectionView = self.TblView.viewWithTag(1) as? UICollectionView
            collectionView?.reloadData()
            
            let collectionView1 = self.TblView.viewWithTag(210) as? UICollectionView
            collectionView1?.reloadData()
            
            let collectionView2 = self.TblView.viewWithTag(2) as? UICollectionView
            collectionView2?.reloadData()
            
            let collectionView3 = self.TblView.viewWithTag(159) as? UICollectionView
            collectionView3?.reloadData()
            
            let collectionView4 = self.TblView.viewWithTag(169) as? UICollectionView
            collectionView4?.reloadData()
            
            let collectionView5 = self.TblView.viewWithTag(961) as? UICollectionView
            collectionView5?.reloadData()
            
            let collectionView6 = self.TblView.viewWithTag(962) as? UICollectionView
            collectionView6?.reloadData()
            
            let collectionView7 = self.TblView.viewWithTag(963) as? UICollectionView
            collectionView7?.reloadData()
            
            let collectionView8 = self.TblView.viewWithTag(964) as? UICollectionView
            collectionView8?.reloadData()
            
            self.TblView.isHidden = false
            self.TblView.reloadData()
        }
    }
    
    //PRAGMA MARK: - Videos Series API   Web Service (ALL)
    func VideosSeriesAPI() ->Void {
        let query = PFQuery(className:"VideoSeries")
        query.order(byDescending: "createdAt")
        query.includeKey("videos")
        query.includeKey("influencers")
        query.whereKey("active", equalTo: true)
        
        if reachability.connection == .none {
            query.cachePolicy = PFCachePolicy.cacheOnly
        }
        else{
            query.cachePolicy = PFCachePolicy.networkOnly
        }
        
        query.whereKey("influencers", equalTo: PFObject(withoutDataWithClassName:"Influencers", objectId:self.ArrVdoAuthorObjId[0] as? String))
        //query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
        query.getFirstObjectInBackground {(objects , error) -> Void in
            if error == nil {
                var StrAvail3 = [String]()
                StrAvail3 = (objects?.allKeys)!
                self.strStaticVideoSeriesLbl = "Video series"
                self.strCreateSeriesVideoName = objects?.value(forKey: "title")! as? String
                
                if(StrAvail3 .contains("videos")){
                    let userPicture = objects?.value(forKey: "videos")! as! NSMutableArray
                    for Data in userPicture {
                        let embed = (Data as AnyObject).value(forKey: "embed") as? String
                        if embed != nil{
                            self.ArrVdoSeriesVdotitle .add((Data as AnyObject).value(forKey:"title")! as? String as Any) //description
                            self.ArrVdoPlayList.add(embed!)
                        }
                    }
                } else{
                    DispatchQueue.main.async {
                        if self.ArrVdoPlayList.count>0{
                            let indexPath = IndexPath(item: 1, section: 0)
                            self.TblView.reloadRows(at: [indexPath], with: .automatic)
                        }else{
                            self.TblView.reloadData()
                            self.ArrHideIndex .add(17)
                        }
                    }
                }
                
                
//                var isfirstTime_videoSeries = Bool()
//                isfirstTime_videoSeries = false
//                for object in objects! {
//                    var StrAvail3 = NSArray()
//                    StrAvail3 = object.allKeys as NSArray
//                    self.strStaticVideoSeriesLbl = "Video series"
//
//                    //
//                    self.strCreateSeriesVideoName = object.value(forKey: "title")! as? String
//                    //
//
//                    if(StrAvail3 .contains("videos")){
//                        let userPicture = object.value(forKey: "videos")! as! NSMutableArray
//
//                        for Data in userPicture {
//                            let embed = (Data as AnyObject).value(forKey: "embed") as? String
//                            if embed != nil{
//                                if self.SelectedVdoObjId == embed{
//                                 //   self.strCreateVideoName = object.value(forKey: "title")! as? String
//                                    self.strStaticVideoSeriesLbl = "Video series"
//                                    self.ArrVdoSeriesVdotitle .add((Data as AnyObject).value(forKey:"title")! as? String as Any) //description
//                                    self.ArrVdoPlayList .add(embed as Any)
//                                    isfirstTime_videoSeries = true
//                                }
//
//
//                            }
//                        }
//                    }
//                    else{
//                        print("Videos Series Not Contains videos")
//                    }
//                    if isfirstTime_videoSeries == true{
//                        break
//                    }  else{
//                        self.ArrVdoPlayList = NSMutableArray()
//                    }
//                }
                
               
            }
            else{
                DispatchQueue.main.async {
                    if self.ArrVdoPlayList.count>0{
                        let indexPath = IndexPath(item: 1, section: 0)
                        self.TblView.reloadRows(at: [indexPath], with: .automatic)
                    }else{
                        self.TblView.reloadData()
                        self.ArrHideIndex .add(17)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Video  Web Service
    func VideosAPI() ->Void {
        let query = PFQuery(className:"Videos")
        query.order(byDescending: "createdAt")
        query.limit = 5
        query.skip = arrVdoEmbed.count
        query.whereKey("influencer", contains: self.ArrVdoAuthorObjId[0] as? String)
        query.includeKey("influencer")
        query.whereKey("active", equalTo: true)
        query.whereKey("embed", notEqualTo: self.SelectedVdoObjId)
        
        if reachability.connection == .none {
            query.cachePolicy = PFCachePolicy.cacheOnly
        } else{
            if query.hasCachedResult == true{
                query.cachePolicy = PFCachePolicy.cacheThenNetwork
                query.maxCacheAge = 0
            }  else{
                query.cachePolicy = PFCachePolicy.networkOnly
            }
        }
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if objects!.count > 0 {
                    for object in objects! {
                        
                        let VdosData = VideosCellModel()
                        
                        self.ArrVdoObjId .add(object.objectId as Any)
                        VdosData.ObjId = object.objectId
                        
                        var Time1 = NSDate()
                        Time1 = object.createdAt! as NSDate
                        self.arrVdoUpdatedTime .add(Time1)
                        VdosData.UpdatedTime = Time1
                        
//----------------------------------
                    
                        if let embed = object.value(forKey: "embed") as? String {
                            self.arrVdoEmbed .add(embed)
                            VdosData.Embed = embed
                            
                            if self.reachability.connection == .none {
                                let urlString = "https://i.ytimg.com/vi/\(embed as NSString)/maxresdefault.jpg"
                                self.ArrVideoURL.add(urlString)
                            } else{
                                if self.ArrVideoURL.count <= 2{
                                    self.GetViewsCountAPI1(strVideoID:embed as NSString)
                                }
                                else{
                                    self.GetViewsCountAPI(strVideoID:embed as NSString)
                                }
                            }
                        } else{
                            self.arrVdoEmbed .add("")
                            VdosData.Embed = ""
                            self.GetViewsCountAPI(strVideoID:"None" as NSString)
                            self.ArrHideIndex .add(18)
                            self.ArrHideIndex .add(19)
                        }
                        
            //----------------------------------
                        if let name = object.value(forKey: "title") as? String {
                            self.arrVdoNameDesc .add(name)
                            VdosData.Description = name
                        } else{
                            self.arrVdoNameDesc .add("")
                            VdosData.Description = ""
                        }
                        self.arrVdoDataModel.append(VdosData)
                    }
                    if self.arrVdoDataModel.count == 0{
                        self.ArrHideIndex .add(18)
                        self.ArrHideIndex .add(19)
                    }
                    
                    DispatchQueue.main.async {
                        self.reloadTblData()
                    }
                }
            }
        }
    }
  
//PRAGMA MARK: - Button Save Video
    @IBAction func BtnSAVE(_ sender: UIButton) {
        let buttonTitle = btnsave.title(for: .normal)
        if buttonTitle=="SAVED"{
            PFCloud.callFunction(inBackground: "saveVideo", withParameters: ["videoId": self.ArrVdoObjId[0] as? String as Any ,"className" : "Videos" , "remove":"yes"]) {
                (ratings, error) in
                if !(error != nil) {
                    self.btnsave.setTitle("SAVE", for: UIControlState .normal)
                    self.btnsave.backgroundColor = Utility().hexStringToUIColor(hex: "48A3D1")
                }
                else{
                    print(error as Any)
                }
            }
        }
        else{
            let pUserobjectId  = UserDefaults.standard.value(forKey: "UserID") as? String
            if pUserobjectId == nil{
                let storyboard = UIStoryboard(name: "Main" , bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginVc") as! LoginVc
                self.present(vc, animated: true, completion: nil)
            }
            else{
                //
                PFCloud.callFunction(inBackground: "saveVideo", withParameters: ["videoId": self.ArrVdoObjId[0] as? String as Any ,"className" : "Videos"]) {
                    (ratings, error) in
                    if !(error != nil) {
                        Mixpanel.mainInstance().identify(
                            distinctId: Mixpanel.mainInstance().distinctId)
                        Mixpanel.mainInstance().track(event: "Save_Video")
                        
                        self.btnsave.setTitle("SAVED", for: UIControlState .normal)
                        self.btnsave.backgroundColor = UIColor .gray
                    }
                    else{
                        print(error as Any)
                    }
                }
            }
        }
    }
    
    //PRAGMA  MARK: - Save Image List API  Web Service
    func SaveImageListAPI() ->Void {
        self.ArrImagesaveExistingID = NSMutableArray()
         self.ArrImagesaveID = NSMutableArray()
        let pUserobjectId  = UserDefaults.standard.value(forKey: "UserID") as? String
        let query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: pUserobjectId as Any)
        query.includeKey("videos")
        query.whereKey("active", equalTo: true)
        
        if reachability.connection == .none {
            query.cachePolicy = PFCachePolicy.cacheOnly
        }
        else{
            if query.hasCachedResult == true{
                query.cachePolicy = PFCachePolicy.cacheThenNetwork
            }
            else{
                query.cachePolicy = PFCachePolicy.networkOnly
            }
        }
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    let relation : PFRelation =  object.relation(forKey: "videos")
                    let querycollabs = relation.query()
                    
                    if self.reachability.connection == .none {
                        querycollabs.cachePolicy = PFCachePolicy.cacheOnly
                    }
                    else{
                        querycollabs.cachePolicy = PFCachePolicy.networkOnly
                    }
                    querycollabs.findObjectsInBackground { (objectscollabs: [PFObject]?, error: Error?) -> Void in
                        if error == nil {
                            for object12 in objectscollabs! {
                                self.ArrImagesaveID.add(object12.objectId as Any)
                                let influencer = object12.value(forKey: "influencer") as! PFObject
                                self.ArrImagesaveExistingID .add(influencer.objectId as Any)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }
    }
    
    //PRAGMA  MARK: - User  Web Service
    func UserAPI() {
        self.ArrsaveGymsObjID = NSMutableArray()
        let arrColumnNames = ["gyms" , "videoproductions" , "apparels" , "supplements"]
        let query = PFQuery(className:"_User")
        query.whereKey("objectId", contains: UserDefaults.standard.value(forKey: "UserID") as? String)
        query.includeKey("gyms")
        query.includeKey("videoproductions")
        query.includeKey("apparels")
        query.includeKey("supplements")
        
        if reachability.connection == .none {
            query.cachePolicy = PFCachePolicy.cacheOnly
        } else{
            if query.hasCachedResult == true{
                query.cachePolicy = PFCachePolicy.cacheThenNetwork
                query.maxCacheAge = 0
            } else{
                query.cachePolicy = PFCachePolicy.networkOnly
            }
        }
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                for object in objects! {
                    for index in arrColumnNames {
                        var StrAvail1 = NSArray()
                        StrAvail1 = object.allKeys as NSArray
                        
                        if(StrAvail1 .contains(index)){
                            let relation : PFRelation =  object.relation(forKey: index)
                            let querygyms = relation.query()
                            
                            if self.reachability.connection == .none {
                                querygyms.cachePolicy = PFCachePolicy.cacheOnly
                            }
                            else{
                                querygyms.cachePolicy = PFCachePolicy.networkOnly
                            }
                            querygyms.findObjectsInBackground { (objectsgyms: [PFObject]?, error: Error?) -> Void in
                                
                                if error == nil {
                                    for object12 in objectsgyms! {
                                        let objectId = object12.value(forKeyPath: "objectId") as Any
                                        self.ArrsaveGymsObjID .add(objectId)
                                    }
                                } else{
                                    print("Not Any Followed")
                                }
                            }
                        } else{
                            print("Not Contains")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.TblView .reloadData()
                }
            }
            DispatchQueue.main.async {
                self.TblView .reloadData()
            }
        }
    }
    
    
    //PRAGMA MARK: - Get Views Count And Video Time
    func GetViewsCountAPI(strVideoID: NSString) ->Void {
        if strVideoID == "None"{
            self.ArrTempVdoViewsCount.add("0 Views")
            self.ArrVideoURL.add("")
        } else{
            DispatchQueue.main.async(execute: {
                let urlString = "https://www.googleapis.com/youtube/v3/videos?part=contentDetails%2C+snippet%2C+statistics&id=\(strVideoID)&key=AIzaSyC4j_mjutz5RKqSaCV86qEBSoUGfjyygFg"
                
                let request = URLRequest(url: URL(string: urlString)!)
                let session = URLSession.shared
                
                let task = session.dataTask(with: request,
                                            completionHandler: { data, response, error -> Void in
                                                // do my thing...
                                                if error != nil
                                                {
                                                    self.ArrTempVdoViewsCount.add("0 Views")
                                                    self.ArrVideoURL.add("")
                                                }
                                                else {
                                                    do {
                                                        
                                                        let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                                                        let arritems = parsedData["items"] as? [[String: AnyObject]]
                                                        
                                                        if arritems?.count != 0{
                                                            let statistics = arritems![0]["statistics"] as? [String: AnyObject]
                                                            let snippet = arritems![0]["snippet"] as? [String: AnyObject]
                                                            let thumbnails = snippet!["thumbnails"] as? [String: AnyObject]
                                                            for strKey in thumbnails!{
                                                                if  strKey.key == "maxres"{
                                                                    let Arrurl = strKey.value as! NSDictionary
                                                                    let strUrl = Arrurl.value(forKeyPath: "url")
                                                                    self.ArrVideoURL.add(strUrl!)
                                                                    break
                                                                    //
                                                                }
                                                                else if  strKey.key == "standard"{
                                                                    let Arrurl = strKey.value as! NSDictionary
                                                                    let strUrl = Arrurl.value(forKeyPath: "url")
                                                                    self.ArrVideoURL.add(strUrl!)
                                                                    break
                                                                }
                                                                else if  strKey.key == "high"{
                                                                    let Arrurl = strKey.value as! NSDictionary
                                                                    let strUrl = Arrurl.value(forKeyPath: "url")
                                                                    self.ArrVideoURL.add(strUrl!)
                                                                    break
                                                                }
                                                            }
                                                            
                                                            for strKey in statistics! {
                                                                if  strKey.key == "viewCount"{
                                                                    self.ArrTempVdoViewsCount.add("\(strKey.value) Views")
                                                                }
                                                            }
                                                        }
                                                        else{
                                                            self.ArrTempVdoViewsCount.add("0 Views")
                                                            self.ArrVideoURL.add("")
                                                        }
                                                    }
                                                    catch let error as NSError
                                                    {
                                                        print("error is" ,error)
                                                    }
                                                }
                                                
                })
                task.resume()
            })
        }
        
    }
    
    //PRAGMA MARK: - Get Views Count And Video Time
    func GetViewsCountAPI1(strVideoID: NSString) ->Void {
        if strVideoID == "None"{
            self.ArrTempVdoViewsCount.add("0 Views")
            self.ArrVideoURL.add("")
        } else{
            let urlString = "https://www.googleapis.com/youtube/v3/videos?part=contentDetails%2C+snippet%2C+statistics&id=\(strVideoID)&key=AIzaSyC4j_mjutz5RKqSaCV86qEBSoUGfjyygFg"
            
            let request = URLRequest(url: URL(string: urlString)!)
            let session = URLSession.shared
            var gotResp = false
            
            let task = session.dataTask(with: request,
                                        completionHandler: { data, response, error -> Void in
                                            // do my thing...
                                            if error != nil
                                            {
                                                self.ArrTempVdoViewsCount.add("0 Views")
                                                self.ArrVideoURL.add("")
                                            }
                                            else {
                                                do {
                                                    
                                                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                                                    let arritems = parsedData["items"] as? [[String: AnyObject]]
                                                    
                                                    if arritems?.count != 0{
                                                        let statistics = arritems![0]["statistics"] as? [String: AnyObject]
                                                        let snippet = arritems![0]["snippet"] as? [String: AnyObject]
                                                        let thumbnails = snippet!["thumbnails"] as? [String: AnyObject]
                                                        for strKey in thumbnails!{
                                                            if  strKey.key == "maxres"{
                                                                let Arrurl = strKey.value as! NSDictionary
                                                                let strUrl = Arrurl.value(forKeyPath: "url")
                                                                self.ArrVideoURL.add(strUrl!)
                                                                break
                                                                //
                                                            }
                                                            else if  strKey.key == "standard"{
                                                                let Arrurl = strKey.value as! NSDictionary
                                                                let strUrl = Arrurl.value(forKeyPath: "url")
                                                                self.ArrVideoURL.add(strUrl!)
                                                                break
                                                            }
                                                            else if  strKey.key == "high"{
                                                                let Arrurl = strKey.value as! NSDictionary
                                                                let strUrl = Arrurl.value(forKeyPath: "url")
                                                                self.ArrVideoURL.add(strUrl!)
                                                                break
                                                            }
                                                            
                                                            
                                                        }
                                                        
                                                        for strKey in statistics! {
                                                            if  strKey.key == "viewCount"{
                                                                self.ArrTempVdoViewsCount.add("\(strKey.value) Views")
                                                            }
                                                        }
                                                        
                                                    }
                                                    else{
                                                        self.ArrTempVdoViewsCount.add("0 Views")
                                                        self.ArrVideoURL.add("")
                                                    }
                                                }
                                                catch let error as NSError
                                                {
                                                    print("error is" ,error)
                                                }
                                            }
                                            
                                            gotResp = true
            })
            task.resume()
            // block thread until completion handler is called
            while !gotResp {
                // wait
            }
            print("Got response in main thread")
        }
    }
    
    //PRAGMA MARK: - Button Share VideoURL
    @IBAction func BtnShare(_ sender: UIButton) {
        let StrShareVideoURL = "https://mygym-us-1.herokuapp.com/influencers/\(InfluencerUrlSite)/\(videoObjectId)"
        let activityViewController = UIActivityViewController(activityItems: [StrShareVideoURL], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.message, UIActivityType.mail,UIActivityType.print, UIActivityType.copyToPasteboard, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll,UIActivityType.postToFlickr]
        
        present(activityViewController, animated: true, completion: {})
    }
}

extension PlayView: UICollectionViewDelegate , UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return self.ArrVdoPlayList.count
        } else if collectionView.tag == 159 {
            return self.arrApparelDataModel.count
        } else if collectionView.tag == 169 {
            return self.arrSpplmtDataModel.count
        } else   if collectionView.tag == 2 {
            return self.ArrCollabs.count
        } else   if collectionView.tag == 210 {
            return self.arrGymDataModel.count
        } else   if collectionView.tag == 961 { //
            return self.arrEquipementsDataModel.count
        } else   if collectionView.tag == 962 {
            return self.arrMealprepDataModel.count
        } else   if collectionView.tag == 963 {
            return self.arrSponsorsDataModel.count
        } else   if collectionView.tag == 964 {
            return self.arrFoodCompanyDataModel.count
        } else   if collectionView.tag == 965 {
            return self.arrCoachingDataModel.count
        } else   if collectionView.tag == 966 {
            return self.arrAccessoriesDataModel.count
        } else   if collectionView.tag == 967 {
            return self.arrVdoProductionDataModel.count
        }  else{
            return self.videoFeaturedImgeData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell:PlayViewSeriesCollCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateLifeCollCell", for: indexPath) as! PlayViewSeriesCollCell
            if ArrVdoPlayList.count > 0{
              //  let VdoVw = cell.contentView.viewWithTag(15) as! UIImageView
                let Lbl_BackgroundImg = cell.contentView.viewWithTag(1500) as? UILabel
                let Lbl_vdoTitle = cell.contentView.viewWithTag(1510) as? UILabel
               
                Lbl_BackgroundImg?.layer.cornerRadius = (Lbl_BackgroundImg?.bounds.size.height)!/2
                Lbl_BackgroundImg?.layer.masksToBounds = true
                cell.imgCell.layer.cornerRadius = 18
                
                Lbl_vdoTitle?.text = ArrVdoSeriesVdotitle[indexPath.row] as? String
                let urlString = "https://i.ytimg.com/vi/\(ArrVdoPlayList[indexPath.row] as! NSString)/maxresdefault.jpg"
                cell.imgCell.sd_setImage(with: URL(string: "\(urlString)"), placeholderImage: UIImage(named: "VideoDefaultImg.png"))
                if SDImageCache.shared().imageFromDiskCache(forKey: urlString ) == nil {
                    let urlString = "https://i.ytimg.com/vi/\(ArrVdoPlayList[indexPath.row] as! NSString)/mqdefault.jpg"
                    cell.imgCell.sd_setImage(with: URL(string: "\(urlString)"), placeholderImage: UIImage(named: "VideoDefaultImg.png"))
                }
            }
            return cell
        }
            
        else if collectionView.tag == 2{
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollabsCollCell", for: indexPath)
            if(ArrCollabsName.count>0){
                let lbl23 = cell.contentView.viewWithTag(71) as! UILabel
                lbl23.text = ArrCollabsName[indexPath.row] as? String
            }
            if(ArrCollabs.count>0){
                let imgVw = cell.contentView.viewWithTag(70) as! UIImageView
                var isImage = false
                imgVw.image = nil
                let userPicture = ArrCollabs[indexPath.row] as? PFFile
                userPicture?.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                    if (error == nil) {
                        let image = UIImage(data:imageData!)
                        imgVw.image = image
                        isImage = true
                    }
                })
                if isImage == false{
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell
        }
            
        else if collectionView.tag == 159{
            let cell1:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ApparelCollCell", for: indexPath)
            let lblName = cell1.contentView.viewWithTag(318) as! UILabel
            let lblDiscountCode = cell1.contentView.viewWithTag(520) as! UILabel
            let imgVw = cell1.contentView.viewWithTag(217) as! UIImageView
            
            let cellAttribute = self.arrApparelDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                    lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell1
        }
            
        else if collectionView.tag == 169{
            let cell1:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SupplementCollCell", for: indexPath)
            let lblName = cell1.contentView.viewWithTag(320) as! UILabel
            let lblDiscountCode = cell1.contentView.viewWithTag(420) as! UILabel
            let imgVw = cell1.contentView.viewWithTag(117) as! UIImageView
           
            let cellAttribute = self.arrSpplmtDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                    lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell1
        }
            
        else if collectionView.tag == 210 {
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GymCollView", for: indexPath)
            let lblName = cell.contentView.viewWithTag(600) as! UILabel
            let lblDiscountCode = cell.contentView.viewWithTag(580) as! UILabel
            let imgVw = cell.contentView.viewWithTag(7) as! UIImageView
            
            let cellAttribute = self.arrGymDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                    lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell
        }
            
        else if collectionView.tag == 961 {
            let cell1:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EquipCollCell", for: indexPath)
            let lblName = cell1.contentView.viewWithTag(1002) as! UILabel
            let lblDiscountCode = cell1.contentView.viewWithTag(1003) as! UILabel
            let imgVw = cell1.contentView.viewWithTag(1001) as! UIImageView
            
            let cellAttribute = self.arrEquipementsDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                    lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell1
        }
            
        else if collectionView.tag == 962 {
            let cell1:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MealPrepCollCell", for: indexPath)
            let lblName = cell1.contentView.viewWithTag(1005) as! UILabel
            let lblDiscountCode = cell1.contentView.viewWithTag(1006) as! UILabel
            let imgVw = cell1.contentView.viewWithTag(1004) as! UIImageView
            
            let cellAttribute = self.arrMealprepDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                    lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell1
        }
            
        else if collectionView.tag == 963 {
            let cell1:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SponsorCollCell", for: indexPath)
            let lblName = cell1.contentView.viewWithTag(1008) as! UILabel
            let lblDiscountCode = cell1.contentView.viewWithTag(1009) as! UILabel
            let imgVw = cell1.contentView.viewWithTag(1007) as! UIImageView
            
            let cellAttribute = self.arrSponsorsDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                    lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell1
        }
            
        else if collectionView.tag == 964 {
            let cell1:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCompCollCell", for: indexPath)
            let lblName = cell1.contentView.viewWithTag(1011) as! UILabel
            let lblDiscountCode = cell1.contentView.viewWithTag(1012) as! UILabel
            let imgVw = cell1.contentView.viewWithTag(1010) as! UIImageView
            
            let cellAttribute = self.arrFoodCompanyDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                     lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell1
        }
            
        else if collectionView.tag == 965 {
            let cell1:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoachingCollCell", for: indexPath)
            let lblName = cell1.contentView.viewWithTag(1052) as! UILabel
            let lblDiscountCode = cell1.contentView.viewWithTag(1053) as! UILabel
            let imgVw = cell1.contentView.viewWithTag(1051) as! UIImageView
            
            let cellAttribute = self.arrCoachingDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                     lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell1
        }
            
        else if collectionView.tag == 966 {
            let cell1:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccesoriesCollCell", for: indexPath)
            let lblName = cell1.contentView.viewWithTag(1055) as! UILabel
            let lblDiscountCode = cell1.contentView.viewWithTag(1056) as! UILabel
            let imgVw = cell1.contentView.viewWithTag(1054) as! UIImageView
            
            let cellAttribute = self.arrAccessoriesDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                     lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
            return cell1
        }
            
        else if collectionView.tag == 967 {
            let cell1:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoProductioCollCell", for: indexPath)
            let lblName = cell1.contentView.viewWithTag(376) as! UILabel
            let lblDiscountCode = cell1.contentView.viewWithTag(377) as! UILabel
            let imgVw = cell1.contentView.viewWithTag(375) as! UIImageView
            
            let cellAttribute = self.arrVdoProductionDataModel[indexPath.row]
            
            if let val = cellAttribute.name {
                lblName.text = val
            }
            if let valCode = cellAttribute.Code {
                if valCode == "" {
                     lblDiscountCode.text = ""
                }else{
                    lblDiscountCode.isHidden = false
                    lblDiscountCode.text = "discount:\n\(valCode)"
                }
            }
            if let userPicture = cellAttribute.image {
                imgVw.image = nil
                if type(of: userPicture) == PFFile.self {
                    if (userPicture.value(forKey: "url") as? String) != nil {
                        let url = userPicture.value(forKey: "url") as? String
                        imgVw.sd_setImage(with: URL(string: "\(url!)"))
                    } else {
                        imgVw.image = UIImage(named: "placeholder.png")!
                    }
                } else {
                    imgVw.image = UIImage(named: "placeholder.png")!
                }
                imgVw.layer.cornerRadius = imgVw.frame.size.height/2
                imgVw.clipsToBounds = true
            }
             return cell1
        }
            
        else{
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCollCell", for: indexPath)
            if(videoFeaturedImgeData.count>0){
                let imgVw = cell.contentView.viewWithTag(300) as! UIImageView
                var isImage = false
                imgVw.image = nil
                let userPicture = videoFeaturedImgeData[0] as? PFFile
                userPicture?.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
                    if (error == nil) {
                        let image = UIImage(data:imageData!)
                        imgVw.image = image
                        isImage = true
                    }
                })
                if isImage == false{
                    imgVw.image = UIImage(named: "VideoDefaultImg.png")!
                }
                imgVw.layer.cornerRadius = 5.0
                imgVw.clipsToBounds = true
            }
            return cell
        }
    }
    
//MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main" , bundle: nil)
        if collectionView.tag == 1{
            if reachability.connection != .none {
                PlayVdo.playerVars = ["playsinline": 1 as AnyObject  ,  "showinfo": 0 as AnyObject]
                PlayVdo.loadVideoID(ArrVdoPlayList[indexPath.row] as! String)
                PlayVdo.play()
            }
        }
        if collectionView.tag == 2{
            let vc = storyboard.instantiateViewController(withIdentifier: "InfluencersProfileVC") as! InfluencersProfileVC
            vc.SelectedClassNames = "Influencers"
            vc.SelectedObjId = (self.ArrCollabsObjId[indexPath.row] as! NSString) as String
            vc.SelectedName = (self.ArrCollabsName[indexPath.row] as! NSString) as String
            let pUserobjectId  = UserDefaults.standard.value(forKey: "UserID") as? String
            if pUserobjectId == nil{
                vc.FollowOrNot = "FOLLOW"
            } else{
                if ArrImagesaveExistingID .contains(self.ArrCollabsObjId[indexPath.row] as! NSString){
                    vc.FollowOrNot = "FOLLOWING"
                }else{
                    vc.FollowOrNot = "FOLLOW"
                }
            }
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag == 3{
            if self.videoFeaturedUrl.count>0{
                var StrUrl = NSString()
                StrUrl  = (videoFeaturedUrl[indexPath.row]  as? NSString)!
                if let url = URL(string: "\(StrUrl)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        
        if collectionView.tag == 159{
            let vc = storyboard.instantiateViewController(withIdentifier: "ApparelNdSponsorVC") as! ApparelNdSponsorVC
            let cellAttribute = self.arrApparelDataModel[indexPath.row]
            vc.SelectedApparelObjId = cellAttribute.ObjId! as NSString
            if ArrsaveGymsObjID .contains(cellAttribute.ObjId!){
                vc.SaveOrNot = "SAVED"
            } else{
                vc.SaveOrNot = "SAVE"
            }
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag == 169{
            let vc = storyboard.instantiateViewController(withIdentifier: "SupplementMapVC") as! SupplementMapVC
            let cellAttribute = self.arrSpplmtDataModel[indexPath.row]
            vc.SelectedSupplementObjId = cellAttribute.ObjId! as NSString
            if ArrsaveGymsObjID .contains(cellAttribute.ObjId!){
                vc.SaveOrNot = "SAVED"
            }  else{
                vc.SaveOrNot = "SAVE"
            }
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag == 210 {
            let vc = storyboard.instantiateViewController(withIdentifier: "GymDetailVC") as! GymDetailVC
            let cellAttribute = self.arrGymDataModel[indexPath.row]
            vc.SelectedGymObjId = cellAttribute.ObjId! as NSString
            let pUserobjectId  = UserDefaults.standard.value(forKey: "UserID") as? String
            if pUserobjectId == nil{
                vc.SaveOrNot = "SAVED"
            } else{
                if ArrsaveGymsObjID .contains(cellAttribute.ObjId!){
                    vc.SaveOrNot = "SAVED"
                } else{
                    vc.SaveOrNot = "SAVE"
                }
            }
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag == 963{
            let vc = storyboard.instantiateViewController(withIdentifier: "InfluencersProfileVC") as! InfluencersProfileVC
            let cellAttribute = self.arrSponsorsDataModel[indexPath.row]
            vc.SelectedClassNames = "Sponsors"
            vc.SelectedObjId = (cellAttribute.ObjId! as NSString) as String
            vc.SelectedName = cellAttribute.name!
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag == 962 {
            let vc = storyboard.instantiateViewController(withIdentifier: "InfluencersProfileVC") as! InfluencersProfileVC
            let cellAttribute = self.arrMealprepDataModel[indexPath.row]
            vc.SelectedClassNames = "MealPrep"
            vc.SelectedObjId = (cellAttribute.ObjId! as NSString) as String
            vc.SelectedName = cellAttribute.name!
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag == 964 {
            let vc = storyboard.instantiateViewController(withIdentifier: "InfluencersProfileVC") as! InfluencersProfileVC
            let cellAttribute = self.arrFoodCompanyDataModel[indexPath.row]
            vc.SelectedClassNames = "FoodCompanies"
            vc.SelectedObjId = (cellAttribute.ObjId! as NSString) as String
            vc.SelectedName = cellAttribute.name!
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag == 961 {
            let vc = storyboard.instantiateViewController(withIdentifier: "InfluencersProfileVC") as! InfluencersProfileVC
            let cellAttribute = self.arrEquipementsDataModel[indexPath.row]
            vc.SelectedClassNames = "Equipments"
            vc.SelectedObjId = (cellAttribute.ObjId! as NSString) as String
            vc.SelectedName = cellAttribute.name!
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag ==  965 {
            let vc = storyboard.instantiateViewController(withIdentifier: "InfluencersProfileVC") as! InfluencersProfileVC
            let cellAttribute = self.arrCoachingDataModel[indexPath.row]
            vc.SelectedClassNames = "Coaching"
            vc.SelectedObjId = (cellAttribute.ObjId! as NSString) as String
            vc.SelectedName = cellAttribute.name!
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag ==  966 {
            let vc = storyboard.instantiateViewController(withIdentifier: "InfluencersProfileVC") as! InfluencersProfileVC
            let cellAttribute = self.arrAccessoriesDataModel[indexPath.row]
            vc.SelectedClassNames = "Accessories"
            vc.SelectedObjId = (cellAttribute.ObjId! as NSString) as String
            vc.SelectedName = cellAttribute.name!
            self.present(vc, animated: true, completion: nil)
        }
        
        if collectionView.tag ==  967 {
            let vc = storyboard.instantiateViewController(withIdentifier: "InfluencersProfileVC") as! InfluencersProfileVC
            let cellAttribute = self.arrVdoProductionDataModel[indexPath.row]
            vc.SelectedClassNames = "VideoProductions"
            vc.SelectedObjId = (cellAttribute.ObjId! as NSString) as String
            vc.SelectedName = cellAttribute.name!
            self.present(vc, animated: true, completion: nil)
        }
    }
}

