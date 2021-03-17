import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import CircularProgress from '@material-ui/core/CircularProgress';
import Checkbox from '@material-ui/core/Checkbox';
import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormControl from '@material-ui/core/FormControl';
import FormLabel from '@material-ui/core/FormLabel';
import { format } from 'date-fns';
import { useSnackbar } from 'notistack';
import Multiselect from './inputs/Multiselect';
import DateInput from './inputs/Date';
import Fields from './inputs/Fields';
import DownloadDialog from './DownloadDialog';
import RangeSlider from './inputs/RangeSlider';
import useDebounce from './useDebounce';
import {
  fields, vCountries, vLanguages, vCategories, vSources, vDuplicate
} from './options.js';

const apiBase = process.env.REACT_APP_API_BASE ? process.env.REACT_APP_API_BASE : 'http://localhost:8000';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1
  },
  inputRow: {
    width: 500,
    display: 'flex',
    justifyContent: 'space-between',
    paddingRight: 20
  },
  inputFieldsRow: {
    width: 500,
    display: 'flex',
    marginTop: 25,
    marginBottom: 5,
    alignItems: 'center',
    paddingRight: 20
  },
  queryStrRow: {
    width: 500,
    display: 'flex',
    textAlign: 'left',
    background: '#eee',
    fontFamily: 'monospace',
    fontSize: 16,
    padding: 15,
    wordBreak: 'break-word',
    paddingRight: 20
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
    position: 'fixed',
    top: 60,
    bottom: 60,
    left: 0,
    right: 0,
    overflow: 'auto',
    // columns: '500px',
    // columnFill: 'balance',
    // marginTop: 60,
    // marginBottom: 60,
    padding: 30,
    '& > * + *': {
      marginTop: theme.spacing(1),
    }
  },
  '@media screen and (max-width: 1090px)': {
    content: {
      flexDirection: 'row'
    }
  },
  header: {
    position: 'fixed',
    left: 0,
    top: 0,
    right: 0,
    zIndex: 10000
  },
  footer: {
    height: 55,
    position: 'fixed',
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
  },
  selectAll: {
    color: 'darkgray'
  },
  formatLabel: {
    textAlign: 'left'
  }
}));

export default function Container() {
  const classes = useStyles();

  const { enqueueSnackbar, closeSnackbar } = useSnackbar();

  const [stFields, setStFields] = useState(fields);
  const updateFields = (val) => {
    const newState = [...stFields];
    const idx = stFields.indexOf(val);
    if (idx < 0) {
      newState.push(val);
    } else {
      newState.splice(idx, 1);
    }
    if (newState.length === fields.length) {
      setSelectAllFields(true);
    } else {
      setSelectAllFields(false);
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

  const [selectAllFields, setSelectAllFields] = useState(true);
  const selectAllChange = function() {
    if (!selectAllFields) { setStFields(fields); } else { setStFields([]); };
    setSelectAllFields(!selectAllFields);
  }

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
  const [stFormat, setStFormat] = useState("xml");           // checkbox

  const dbText = useDebounce(stText, 500);
  const dbEntityid = useDebounce(stEntityid, 500);
  const dbGeorssid = useDebounce(stGeorssid, 500);
  const dbGuid = useDebounce(stGuid, 500);

  useEffect(() => {
    const jj = (x) => x.length === 0 ? '' : `["${x.join('","')}"]`;
    const fmt = (x) => x === null ? null : format(x, 'yyyy-MM-dd');
    const dd = (x, y) => `["${fmt(x)}","${fmt(y)}"]`;
  
    const url = `${apiBase}/get_ndocs?category=${jj(stCategory)}&country=${jj(stCountry)}&language=${jj(stLanguage)}&source=${jj(stSource)}&duplicate=${jj(stDuplicate)}&pubdate=${dd(stPubdate1,stPubdate2)}&indexdate=${dd(stIndexdate1,stIndexdate2)}&text=${dbText}&tonality=${jj(stTonality)}&entityid=${dbEntityid}&georssid=${dbGeorssid}&guid=${dbGuid}`;
    // &fields=${JSON.stringify(stFields)}
    
    setNDocsLoading(true)
    setNDocsLoaded(false);
    fetch(url)
      .then(response => {
        if (!response.ok) {
          response.text().then(text => {
            enqueueSnackbar(text, { variant: 'error' });
          });
        }
        return response.json();
      })
      .then(data => {
        console.log(data);
        setNDocs(data.n_docs);
        setQueryStr(data.query);
        setNDocsLoading(false);
        setNDocsLoaded(true);
      })
      .catch((err) => {
        const msg = err.message === 'Failed to fetch'
          ? 'Unable to connect to API' : err.message;
        enqueueSnackbar(msg, { variant: 'error' });
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
  
    const url = `${apiBase}/download_docs?category=${jj(stCategory)}&country=${jj(stCountry)}&language=${jj(stLanguage)}&source=${jj(stSource)}&duplicate=${jj(stDuplicate)}&pubdate=${dd(stPubdate1,stPubdate2)}&indexdate=${dd(stIndexdate1,stIndexdate2)}&text=${dbText}&tonality=${jj(stTonality)}&entityid=${dbEntityid}&georssid=${dbGeorssid}&guid=${dbGuid}&fields=${JSON.stringify(stFields)}&path=/tmp/__finder_downloads__/${queryName}&format=${stFormat}`;

    setDocsDownloading(true)
    fetch(url)
      .then(response => {
        if (!response.ok) {
          response.text().then(text => {
            enqueueSnackbar(text, { variant: 'error' });
          });
        }
        return response.json();
      })
      .then(data => {
        setDocsDownloading(false);
        enqueueSnackbar((
          <div>
            {`Query '${queryName}' success...`}
            <Button href={`${apiBase}/static/${queryName}.zip`}>
              Download
            </Button>
          </div>
        ), {
          variant: 'success',
          persist: true
        });
      })
      .catch((err) => {
        const msg = err.message === 'Failed to fetch'
          ? 'Unable to connect to API' : err.message;
        enqueueSnackbar(msg, { variant: 'error' });
        setHasError(true)
        setDocsDownloading(false);
      });
  }

  return (
    <div className={classes.root}>
      <div className={classes.header}>
        <AppBar position="static">
          <Toolbar>
            <Typography variant="h6" className={classes.title}>
              Finder Query Builder
            </Typography>
          </Toolbar>
        </AppBar>
      </div>
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
        <div className={classes.inputRow} >
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
            Document fields to return&nbsp;&nbsp;&nbsp;&nbsp;
            <Checkbox
              checked={selectAllFields}
              name="all"
              color="primary"
              onChange={selectAllChange}  
            />
            <span className={classes.selectAll}>all</span>
          </div>
          <div className={classes.inputRow}>
            <Fields update={updateFields} selectedFields={stFields} />
          </div>
          <div className={classes.inputFieldsRow}>
            <FormControl component="fieldset">
              <FormLabel component="legend" className={classes.formatLabel}>Output format</FormLabel>
              <RadioGroup aria-label="format" name="format1" value={stFormat} onChange={(event) => { setStFormat(event.target.value)}} row>
                <FormControlLabel value="xml" control={<Radio color="primary" />} label="xml" />
                <FormControlLabel value="csv" control={<Radio color="primary" />} label="csv" />
              </RadioGroup>
            </FormControl>
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
          disabled={!(nDocs && nDocs <= 100000) || queryName === ''}
          onClick={downloadDocs}
        >
          Pull Documents
        </Button>
      </div>
      {nDocsLoading && (<CircularProgress className={classes.progress} size={30} />)}
      {nDocsLoaded && typeof nDocs === 'number' && (<div className={classes.ndocs}>{`${nDocs.toLocaleString()} documents`}</div>)}
      <div className={classes.downloadMsg}>
        {!(nDocs && nDocs <= 100000) && ("Cannot run unless <100k documents are in query.")}
        {queryName === '' && (" Query needs a name.")}
      </div>
      <DownloadDialog open={docsDownloading} path={queryName} />
    </div>
  );
}
