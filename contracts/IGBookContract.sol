pragma solidity ^0.5.0;

// Simple Solidity intro/demo contract for IGBook Demo
contract IGBookContract {

  address IGBookAdmin;

  mapping ( bytes32 => notarizedImage) notarizedImages; // this allows to look up notarizedImages by their SHA256notaryHash
  bytes32[] imagesByNotaryHash; // this is images list by SHA256notaryHash

  mapping ( address => User ) Users;   // this allows to look up Users by their ethereum address
  address[] usersByAddress;  // this is users list, by ethereum address

  struct notarizedImage {
    string imageURL;
    uint timeStamp;
  }

  struct User {
    string handle;
    bytes32 city;
    bytes32 state;
    bytes32 country;
    bytes32[] myImages;
  }

  constructor() public payable {  // this is the CONSTRUCTOR, it gets called ONCE only when contract is first deployed
    IGBookAdmin = msg.sender;  // just set the admin, so they can remove bad users or images if needed, but nobody else can
  }

  modifier onlyAdmin() {
	  
	  require(msg.sender == IGBookAdmin);
      // Do not forget the "_;"! It will be replaced by the actual function body when the modifier is used.
      _;
  }

  function removeUser(address badUser) public onlyAdmin returns (bool success) {
    delete Users[badUser];
    return true;
  }

  function removeImage(bytes32 badImage) public onlyAdmin returns (bool success) {
    delete notarizedImages[badImage];
    return true;
  }

  function registerNewUser(string memory handle, bytes32 city, bytes32 state, bytes32 country) public returns (bool success) {
    address thisNewAddress = msg.sender;
    // don't overwrite existing entries, and make sure handle isn't null
    if(bytes(Users[msg.sender].handle).length == 0 && bytes(handle).length != 0){
      Users[thisNewAddress].handle = handle;
      Users[thisNewAddress].city = city;
      Users[thisNewAddress].state = state;
      Users[thisNewAddress].country = country;
      usersByAddress.push(thisNewAddress);  // adds an entry for this user to the user list
      return true;
    } else {
      return false; // either handle was null, or a user with this handle already existed
    }
  }

  function addImageToUser(string memory imageURL, bytes32 SHA256notaryHash) public returns (bool success) {
    address thisNewAddress = msg.sender;
    if(bytes(Users[thisNewAddress].handle).length != 0){ // make sure this user has created an account first
      if(bytes(imageURL).length != 0){   // ) {  // couldn't get bytes32 null check to work, oh well!
        // prevent users from fighting over sha->image listings in the image list, but still allow them to add a personal ref to any sha
        if(bytes(notarizedImages[SHA256notaryHash].imageURL).length == 0) {
          imagesByNotaryHash.push(SHA256notaryHash); // adds entry for this image to our image whitepages
        }
        notarizedImages[SHA256notaryHash].imageURL = imageURL;
        notarizedImages[SHA256notaryHash].timeStamp = block.timestamp; // note that updating an image also updates the timestamp
        Users[thisNewAddress].myImages.push(SHA256notaryHash); // add the image hash to this users .myImages array
        return true;
      } else {
        return false; // either imageURL or SHA256notaryHash was null, couldn't store image
      }
      return true;
    } else {
      return false; // user didn't have an account yet, couldn't store image
    }
  }

  function getUsers() public view returns (address[] memory) { return usersByAddress; }

  function getUser(address userAddress) public view returns (string memory,bytes32,bytes32,bytes32,bytes32[] memory) {
    return (Users[userAddress].handle,Users[userAddress].city,Users[userAddress].state,Users[userAddress].country,Users[userAddress].myImages);
  }

  function getAllImages() public view returns (bytes32[] memory) { return imagesByNotaryHash; }

  function getUserImages(address userAddress) public view returns (bytes32[] memory) { return Users[userAddress].myImages; }

  function getImage(bytes32 SHA256notaryHash) public view returns (string memory,uint) {
    return (notarizedImages[SHA256notaryHash].imageURL,notarizedImages[SHA256notaryHash].timeStamp);
  }

}