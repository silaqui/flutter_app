const functions = require('firebase-functions');
const cors = require('cors')({origin: true});
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const fbAdmin = require('firebase-admin');
const uuid = require('uuid/v4');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const gcconfig = {
    projectId: 'flutterudemycourse',
    keyFilename: 'flutter-products.json'
};

const gcs = require('@google-cloud/storage')(gcconfig);

fbAdmin.initializeApp({
    credential: fbAdmin.credential.cert(require('./flutter-products.json'))
});

exports.storeImage = functions.https.onRequest((req, res) => {
    return cors(req,res,()=>{
        if(req.method !== 'POST'){
            return res.status(500).json({message:'Not allowed.'});
        }
        if(req.headers.authorization || !req.authorization.startsWith('Bearer ')){
            return res.status(401).json({message:'Unauthorized.'});
        }
        let idToken;
        idToken = req.headers.authorization.split('Bearer ')[1];

        const busboy = new Busboy({headers: req.headers});
        let uploadData;
        let oldImagePath;

        busboy.on('file',(filename, file, filename, encoding, mimetype)=>{
            const filePath = path.json(os.tmpdir(),filename);
            uploadData = {filePath: filePath, type: mimetype, name: filename};
            file.pipe(fs.createWriteStream(filePath));
        })

        busboy.on('field',(field,value)=>{
            oldImagePath decodeURIComponent(value);
        })

        busboy.on('finish',()=>{
            const bucket = gcs.bucket('flutterudemycourse.appspot.com');
            cont id = uuid();
            let imagePath = '/images/'+id+'-'+uploadData.name;
            if(oldImagePath){
                imagePath = oldImagePath;
            }

            return fbAdmin.auth().verifyIdToken(idToken)
                .then(decotedToken =>{
                    return bucket.upload(uploadData.filePath,{
                            uploadType: 'media',
                            destination: imagePath,
                            metadata:{
                                metadata:{
                                        contentType: uploadData.type,
                                        firebaseStorageDownloadToken: id
                                }
                            }
                        });
                })
                .then(()=>{
                    return res.status(201).json({
                        imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b' +
                        bucket.name +
                        '/o/' +
                        encodeURIComponet(imagePath) +
                        '?alt=media&token=' +
                        id,
                        imagePath: imagePath
                    });
                })
                .catch(error => {
                    return res.status(401).json({error: 'Niet'})
                });
        });
        return busboy.end(req.rawBody);
    });
});









