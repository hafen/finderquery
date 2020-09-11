import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import CircularProgress from '@material-ui/core/CircularProgress';
import { format } from 'date-fns';
import Multiselect from './inputs/Multiselect';
import DateInput from './inputs/Date';
import Fields from './inputs/Fields';
import DownloadDialog from './DownloadDialog';
import RangeSlider from './inputs/RangeSlider';
import useDebounce from './useDebounce';
import {
  fields, vCountries, vLanguages, vCategories, vSources, vDuplicate
} from './options.js';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1
  },
  inputRow: {
    width: 500,
    display: 'flex',
    justifyContent: 'space-between'
  },
  inputFieldsRow: {
    width: 500,
    display: 'flex',
    marginTop: 25,
    marginBottom: 5
  },
  queryStrRow: {
    width: 500,
    display: 'flex',
    textAlign: 'left',
    background: '#eee',
    fontFamily: 'monospace',
    fontSize: 16,
    padding: 15,
    wordBreak: 'break-word'
  },
  title: {
    flexGrow: 1,
    textAlign: 'left'
  },
  content: {
    display: 'flex',
    flexDirection: 'column',
    flexWrap: 'wrap',
    flex: 'auto',
    padding: 30,
    '& > * + *': {
      marginTop: theme.spacing(1),
    },
    position: 'absolute',
    top: 60,
    bottom: 60,
    left: 0,
    right: 0,
    overflow: 'auto'
  },
  footer: {
    height: 55,
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    background: '#eee',
    lineHeight: '52px',
    display: 'flex',
    justifyContent: 'center',
    placeItems: 'center'
  },
  progress: {
    position: 'fixed',
    bottom: 12,
    left: 12
  },
  ndocs: {
    position: 'fixed',
    left: 18,
    bottom: 18
  },
  downloadMsg: {
    position: 'fixed',
    bottom: 18,
    right: 18
  }
}));

export default function Container() {
  const classes = useStyles();

  const [stFields, setStFields] = useState(fields);
  const updateFields = (val) => {
    const newState = [...stFields];
    const idx = stFields.indexOf(val);
    if (idx < 0) {
      newState.push(val);
    } else {
      newState.splice(idx, 1);
    }
    setStFields(newState);
  }

  const [nDocs, setNDocs] = useState(null)
  const [queryStr, setQueryStr] = useState('')

  const [nDocsLoading, setNDocsLoading] = useState(false)
  const [nDocsLoaded, setNDocsLoaded] = useState(false)
  const [docsDownloading, setDocsDownloading] = useState(false)
  // TODO: use this to add a "download" button or a "close" button
  // const [docsDownloaded, setDocsDownloaded] = useState(false)
  const [hasError, setHasError] = useState(false)

  const [queryName, setQueryName] = useState('');

  const [stCategory, setStCategory] = useState([]);          // mselect
  const [stCountry, setStCountry] = useState([]);            // mselect
  const [stLanguage, setStLanguage] = useState([]);          // mselect
  const [stSource, setStSource] = useState([]);              // mselect
  const [stDuplicate, setStDuplicate] = useState([]);        // mselect
  const [stIndexdate1, setStIndexdate1] = useState(null);    // date
  const [stIndexdate2, setStIndexdate2] = useState(null);    // date
  const [stPubdate1, setStPubdate1] = useState(null);        // date
  const [stPubdate2, setStPubdate2] = useState(null);        // date
  const [stText, setStText] = useState('');                  // text input
  const [stTonality, setStTonality] = useState([-100, 100]); // slider
  const [stEntityid, setStEntityid] = useState('');          // text input
  const [stGeorssid, setStGeorssid] = useState('');          // text input
  const [stGuid, setStGuid] = useState('');                  // text input

  const dbText = useDebounce(stText, 500);
  const dbEntityid = useDebounce(stEntityid, 500);
  const dbGeorssid = useDebounce(stGeorssid, 500);
  const dbGuid = useDebounce(stGuid, 500);

  useEffect(() => {
    const jj = (x) => x.length === 0 ? '' : `["${x.join('","')}"]`;
    const fmt = (x) => x === null ? null : format(x, 'yyyy-MM-dd');
    const dd = (x, y) => `["${fmt(x)}","${fmt(y)}"]`;
  
    const url = `http://localhost:8000/get_ndocs?category=${jj(stCategory)}&country=${jj(stCountry)}&language=${jj(stLanguage)}&source=${jj(stSource)}&duplicate=${jj(stDuplicate)}&pubdate=${dd(stPubdate1,stPubdate2)}&indexdate=${dd(stIndexdate1,stIndexdate2)}&text=${dbText}&tonality=${jj(stTonality)}&entityid=${dbEntityid}&georssid=${dbGeorssid}&guid=${dbGuid}`;
    // &fields=${JSON.stringify(stFields)}
    
    setNDocsLoading(true)
    setNDocsLoaded(false);
    fetch(url)
      .then(response => response.json())
      .then(data => {
        console.log(data);
        setNDocs(data.n_docs);
        setQueryStr(data.query);
        setNDocsLoading(false);
        setNDocsLoaded(true);
      })
      .catch(() => {
        setHasError(true)
        setNDocsLoading(false)
      });
  }, [stCategory,
    stCountry,
    stLanguage,
    stSource,
    stDuplicate,
    stIndexdate1,
    stIndexdate2,
    stPubdate1,
    stPubdate2,
    dbText,
    stTonality,
    dbEntityid,
    dbGeorssid,
    dbGuid]);

  const downloadDocs = () => {
    const jj = (x) => x.length === 0 ? '' : `["${x.join('","')}"]`;
    const fmt = (x) => x === null ? null : format(x, 'yyyy-MM-dd');
    const dd = (x, y) => `["${fmt(x)}","${fmt(y)}"]`;
  
    const url = `http://localhost:8000/download_docs?category=${jj(stCategory)}&country=${jj(stCountry)}&language=${jj(stLanguage)}&source=${jj(stSource)}&duplicate=${jj(stDuplicate)}&pubdate=${dd(stPubdate1,stPubdate2)}&indexdate=${dd(stIndexdate1,stIndexdate2)}&text=${dbText}&tonality=${jj(stTonality)}&entityid=${dbEntityid}&georssid=${dbGeorssid}&guid=${dbGuid}&fields=${JSON.stringify(stFields)}&path=/tmp/${queryName}`;
    
    setDocsDownloading(true)
    fetch(url)
      .then(response => response.json())
      .then(data => {
        setDocsDownloading(false);
      })
      .catch(() => {
        setHasError(true)
        setDocsDownloading(false);
      });
  }

  return (
    <div className={classes.root}>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" className={classes.title}>
            Finder Query Builder
          </Typography>
        </Toolbar>
      </AppBar>
      <div className={classes.content}>
        <div className={classes.inputRow}>
          <TextField
            required
            error={queryName === ''}
            fullWidth
            label="Query name"
            value={queryName}
            onChange={(event) => {
              setQueryName(event.target.value.replace(/\W/g, ''))
            }}
            variant="filled"
          />
        </div>
        <Multiselect label="Category" values={vCategories} setter={setStCategory} />
        <Multiselect label="Country" values={vCountries} setter={setStCountry} />
        <Multiselect label="Language" values={vLanguages} setter={setStLanguage} />
        <Multiselect label="Source" values={vSources} setter={setStSource} />
        <Multiselect label="Duplicate" values={vDuplicate} setter={setStDuplicate} />
        <div className={classes.inputRow}>
          <DateInput label="pubDate start" setter={setStPubdate1} />
          <DateInput label="pubDate end"  setter={setStPubdate2} />
        </div>
        <div className={classes.inputRow}>
          <DateInput label="indexDate start" setter={setStIndexdate1} />
          <DateInput label="indexDate end" setter={setStIndexdate2} />
        </div>
        <div className={classes.inputRow}>
          <TextField
            fullWidth
            label="Text (search in title, description, body text)"
            value={stText}
            onChange={(event) => setStText(event.target.value)}
          />
        </div>
        <div className={classes.inputRow}>
          <RangeSlider value={stTonality} setter={setStTonality} />
        </div>
        <div className={classes.inputRow}>
          <TextField
            fullWidth
            label="entityid"
            value={stEntityid}
            onChange={(event) => setStEntityid(event.target.value)}
          />
        </div>
        <div className={classes.inputRow}>
          <TextField
            fullWidth
            label="georssid"
            value={stGeorssid}
            onChange={(event) => setStGeorssid(event.target.value)}
          />
        </div>
        <div className={classes.inputRow}>
          <TextField
            fullWidth
            label="guid"
            value={stGuid}
            onChange={(event) => setStGuid(event.target.value)}
          />
        </div>
        <div>
          <div className={classes.inputFieldsRow}>
            Document fields to return:
          </div>
          <div className={classes.inputRow}>
            <Fields update={updateFields} selectedFields={stFields} />
          </div>
        </div>
        <div>
          <div className={classes.inputFieldsRow}>
            Query
          </div>
          <div className={classes.queryStrRow}>
            {queryStr}
          </div>        
        </div>
      </div>
      <div className={classes.footer}>
        <Button
          variant="contained"
          color="primary"
          disabled={!(nDocs && nDocs <= 100000)}
          onClick={downloadDocs}
        >
          Download
        </Button>
      </div>
      {nDocsLoading && (<CircularProgress className={classes.progress} size={30} />)}
      {nDocsLoaded && typeof nDocs === 'number' && (<div className={classes.ndocs}>{`${nDocs.toLocaleString()} documents`}</div>)}
      <div className={classes.downloadMsg}>
        {!(nDocs && nDocs <= 100000) && ("Cannot download unless <100k documents are in query.")}
        {queryName === '' && (" Query needs a name.")}
      </div>
      <DownloadDialog open={docsDownloading} path={queryName} />
    </div>
  );
}
